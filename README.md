# DevOps Challenge – SimpleTimeService

## Overview

This project demonstrates a complete DevOps workflow:

* A minimal web application (`SimpleTimeService`)
* Containerization using Docker
* Kubernetes deployment (Deployment + Service)
* Infrastructure provisioning using Terraform (AWS VPC + EKS)

The goal is to showcase infrastructure-as-code, container best practices, and Kubernetes deployment in a reproducible way.

---

## Project Structure

```
.
├── app/              # Application source code and Dockerfile
├── terraform/        # Terraform configuration for AWS infrastructure
├── k8s/              # Kubernetes manifest
└── README.md
```

---

## Prerequisites

Make sure the following tools are installed:

* Docker → https://docs.docker.com/get-docker/
* Terraform → https://developer.hashicorp.com/terraform/downloads
* AWS CLI → https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
* kubectl → https://kubernetes.io/docs/tasks/tools/

---

## AWS Authentication

Configure your AWS credentials:

```
aws configure
```

Provide:

* AWS Access Key
* AWS Secret Key
* Region (ap-south-1)

---

## Build and Push Docker Image

Navigate to the app directory:

```
cd app
```

Build the image:

```
docker build -t <your-dockerhub-username>/simpletimeservice:v1.1 .
```

Push to DockerHub:

```
docker push <your-dockerhub-username>/simpletimeservice:v1.1
```

---

## Deploy Infrastructure (Terraform)

Navigate to terraform directory:

```
cd terraform
```

Initialize Terraform:

```
terraform init
```

Preview changes:

```
terraform plan
```

Apply configuration:

```
terraform apply
```

This will create:

* VPC with public and private subnets
* EKS cluster
* Managed node group (2 nodes, m6a.large)

---

## Connect to EKS Cluster

After deployment:

```
aws eks update-kubeconfig --region ap-south-1 --name sts-app
```


Verify cluster access:

```
kubectl get nodes
```

---

## Deploy Application to Kubernetes

Apply the manifest:

```
kubectl apply -f deployment.yml
```
```
kubectl apply -f service.yml
```

Verify:

```
kubectl get pods
kubectl get svc
```

---

## Access the Application

Since the service type is `ClusterIP`, use port forwarding:

```
kubectl port-forward svc/simpletimeservice 8080:80
```

Then open:

```
http://localhost:8080
```

Expected response:

```json
{
  "timestamp": "2026-04-08T12:34:56.789Z",
  "ip": "127.0.0.1"
}
```

---

## Design Decisions

* **FastAPI (Python)** chosen for simplicity and performance
* **Non-root container user** for security best practices
* **Slim Docker image** to reduce size
* **ClusterIP service** as per requirements
* **Terraform modules** used for maintainability and reusability

---

## Notes

* No secrets or credentials are stored in the repository
* Ensured Docker image is publicly accessible
* Terraform state is stored locally (can be extended to remote backend)

---

## Possible Improvements (Extra Credit)

* Remote Terraform backend (S3 + DynamoDB)
* Helm deployment vi# Particle41 DevOps Challenge — SimpleTimeService

A minimal microservice and supporting cloud-native infrastructure built for the Particle41 DevOps team challenge.

```
.
├── app/
│   ├── main.py            # FastAPI service — returns timestamp + caller IP
│   ├── requirements.txt
│   ├── Dockerfile         # Multi-stage, non-root, minimal image
│   └── microservice.yml   # Deployment, Service, HPA, PDB (production-hardened)
├── terraform/
│   ├── backend.tf         # S3 + DynamoDB remote state
│   ├── main.tf            # VPC, EKS, metrics-server, Prometheus, app deploy
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars   # Sensible defaults
│   └── bootstrap-state.sh # One-time script to create remote-state resources
└── .github/
    └── workflows/
        └── ci.yml         # Build → test → Trivy scan → push → update manifest
```

---

## Task 1 — Deploy SimpleTimeService to any Kubernetes cluster

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| kubectl | ≥ 1.28 | https://kubernetes.io/docs/tasks/tools/ |
| A running Kubernetes cluster | — | any provider, or `minikube` / `kind` locally |

### Deploy

```bash
kubectl apply -f app/microservice.yml
```

That single command creates a Deployment (2 replicas with a Fluent Bit sidecar), a ClusterIP Service, a HorizontalPodAutoscaler, and a PodDisruptionBudget.

Wait for the pods to become ready:

```bash
kubectl rollout status deployment/simpletimeservice
```

### Test

Because the service type is ClusterIP (no external load balancer), use `port-forward` to reach it from your machine:

```bash
kubectl port-forward svc/simpletimeservice 8080:80
```

Then in a second terminal:

```bash
curl http://localhost:8080/
# {"timestamp":"2024-07-01T12:00:00Z","ip":"127.0.0.1"}

curl http://localhost:8080/healthz
# {"status":"ok"}
```

### Verify the non-root requirement

```bash
kubectl exec -it deployment/simpletimeservice -c simpletimeservice -- id
# uid=1000 gid=1000 — not root
```

---

## Task 2 — Deploy VPC + EKS with Terraform

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform | ≥ 1.7 | https://developer.hashicorp.com/terraform/install |
| AWS CLI | ≥ 2.x | https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html |
| kubectl | ≥ 1.28 | https://kubernetes.io/docs/tasks/tools/ |

An AWS IAM user or role with permissions to create VPCs, EKS clusters, EC2 instances, IAM roles, and S3/DynamoDB resources.

### Authenticate to AWS

**Option A — named profile (recommended):**

```bash
aws configure --profile particle41
export AWS_PROFILE=particle41
```

**Option B — environment variables:**

```bash
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

Do **not** commit credentials to the repository.

### Step 1 — bootstrap remote state (one-time only)

```bash
bash terraform/bootstrap-state.sh
```

This creates:
- An S3 bucket (versioned, encrypted, public-access blocked) for state storage
- A DynamoDB table for state locking

Copy the bucket name printed at the end into `terraform/backend.tf`.

### Step 2 — initialise and deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

`terraform apply` provisions:

- A VPC with 2 public and 2 private subnets across 2 AZs
- A NAT Gateway so private-subnet nodes can reach the internet
- An EKS 1.29 cluster with the vpc-cni, coredns, and kube-proxy add-ons
- A managed node group: 2 × `m6a.large` nodes on the **private** subnets
- metrics-server (required for HPA)
- kube-prometheus-stack (Grafana + Prometheus) in the `monitoring` namespace
- The SimpleTimeService application in the `simpletimeservice` namespace

Typical apply time: 15–20 minutes.

### Step 3 — configure kubectl

```bash
$(terraform output -raw configure_kubectl)
# expands to: aws eks update-kubeconfig --region us-east-1 --name particle41-eks
```

### Step 4 — verify

```bash
kubectl get nodes
kubectl get pods -n simpletimeservice
kubectl port-forward -n simpletimeservice svc/simpletimeservice 8080:80
curl http://localhost:8080/
```

### Access Grafana (if `deploy_prometheus = true`)

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# open http://localhost:3000  user: admin  password: changeme
```

### Tear down

```bash
terraform destroy
```

The S3 bucket and DynamoDB table created by `bootstrap-state.sh` are **not** managed by Terraform and must be deleted manually if no longer needed.

---

## CI/CD Pipeline (GitHub Actions)

The pipeline in `.github/workflows/ci.yml` runs on every push to `main` that touches `app/**`.

**Steps:**
1. Lint the Dockerfile with hadolint
2. Build the image
3. Run a smoke test (starts the container, hits `/` and `/healthz`, verifies non-root UID)
4. Scan the image for `CRITICAL` CVEs with Trivy (pipeline fails if any are found)
5. Push `:latest` and `:<git-sha>` tags to DockerHub
6. Pin the new image SHA in `app/microservice.yml` and commit back to `main`

**Required GitHub Secrets** (Settings → Secrets and variables → Actions):

| Secret | Value |
|--------|-------|
| `DOCKERHUB_USERNAME` | your DockerHub username |
| `DOCKERHUB_TOKEN` | a DockerHub access token (not your password) |

Pull requests trigger only the build, test, and scan steps — no push.

---

## Production hardening summary

| Feature | Detail |
|---------|--------|
| Non-root user | `runAsUser: 1000`, `runAsNonRoot: true`, `allowPrivilegeEscalation: false` |
| Read-only root FS | `readOnlyRootFilesystem: true` + `emptyDir` volume for log files |
| Capability drop | `capabilities.drop: [ALL]` on all containers |
| Resource limits | CPU 250m / memory 128Mi (app), CPU 50m / memory 64Mi (Fluent Bit) |
| Health probes | startupProbe + livenessProbe + readinessProbe on `/healthz` |
| Rolling update | `maxSurge: 1 / maxUnavailable: 0` — zero downtime deploys |
| HPA | 2–6 replicas, scales at 60% CPU |
| PodDisruptionBudget | `minAvailable: 1` — safe during node drains |
| Topology spread | Pods spread across nodes to tolerate a single-node failure |
| Fluent Bit sidecar | Structured log shipping from a shared `emptyDir` volume |
| Remote state | S3 (versioned + encrypted) + DynamoDB lock |
| Image scanning | Trivy CRITICAL gate in CI — build fails before bad images ship |a Terraform
* CI/CD pipeline (GitHub Actions)
* Monitoring stack (Prometheus/Grafana)
* Ingress setup for external access

---

## Author

Sai Kumar
DevOps Engineer | AWS | Kubernetes | Terraform

---

## Summary

This project provides a complete, reproducible DevOps workflow:

* Build → Containerize → Deploy → Scale

It is designed to be simple, readable, and production-aligned.
