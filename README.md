# 🚀 DevOps Challenge – SimpleTimeService

## 📌 Overview

This project demonstrates a complete end-to-end DevOps workflow:

- Minimal web application (SimpleTimeService)
- Containerization using Docker (non-root, secure)
- Kubernetes deployment (Deployment + Service)
- Infrastructure provisioning using Terraform (AWS VPC + EKS)
- CI/CD automation using GitHub Actions

The goal is to showcase infrastructure-as-code, container best practices, and automated deployment workflows in a reproducible and production-aligned manner.

---

## 🧱 Project Structure

.
├── app/              # Application source code and Dockerfile
├── terraform/        # Terraform configuration for AWS infrastructure
├── k8s/              # Kubernetes manifests
├── .github/workflows # CI/CD pipeline
└── README.md

---

## ⚙️ Prerequisites

Ensure the following tools are installed:

- Docker → https://docs.docker.com/get-docker/
- Terraform → https://developer.hashicorp.com/terraform/downloads
- AWS CLI → https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
- kubectl → https://kubernetes.io/docs/tasks/tools/
- GitHub account (for CI/CD)

---

## 🔐 AWS Authentication

Configure AWS credentials:

aws configure

Provide:
- AWS Access Key
- AWS Secret Key
- Region: ap-south-1

---

## 🐳 Build and Push Docker Image (Manual - Optional)

Note: This step is automated via CI/CD. Manual execution is optional.

cd app
docker build -t <your-dockerhub-username>/simpletimeservice:v1.1 .
docker push <your-dockerhub-username>/simpletimeservice:v1.1

---

## ☁️ Deploy Infrastructure (Terraform)

cd terraform
terraform init
terraform plan
terraform apply

This provisions:
- VPC with public & private subnets
- EKS cluster
- Managed node group (2 × m6a.large)

---

## 🔗 Connect to EKS Cluster

aws eks update-kubeconfig --region ap-south-1 --name sts-app
kubectl get nodes

---

## 🚀 Deploy Application to Kubernetes

cd ../k8s
kubectl apply -f microservice.yml

Verify:

kubectl get pods
kubectl get svc

---

## 🌐 Access the Application

kubectl port-forward svc/simpletimeservice 8080:80

Open:
http://localhost:8080

Expected response:

{
  "timestamp": "2026-04-08T12:34:56.789Z",
  "ip": "127.0.0.1"
}

---

## ⚙️ CI/CD Pipeline (GitHub Actions)

### 🔑 Required Secrets

Configure in GitHub → Settings → Secrets:

- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN

---

## 🚦 Pipeline Triggers

- Push to main
  - Builds, tests, scans, pushes image
  - Updates Kubernetes manifest automatically

- Pull Request to main
  - Runs build + test only (no push)

---

## 🔄 Pipeline Stages

1. Lint
   - Dockerfile linting using Hadolint

2. Build
   - Docker image built using Buildx
   - Cached layers for faster builds

3. Test (Smoke Test)
   - Container is started
   - Endpoints validated:
     - / → returns timestamp & IP
     - /healthz → returns status
   - Ensures container runs as non-root user

4. Security Scan
   - Image scanned using Trivy
   - Pipeline fails on CRITICAL vulnerabilities

5. Push Image
   - Tags:
     - <git-sha> (immutable versioning)

6. Auto Update Kubernetes Manifest
   - Updates microservice.yml with latest image SHA
   - Commits back to repository automatically

---

## 🔁 Deployment Flow

Code Push → GitHub Actions →
Build → Test → Scan → Push →
Update Manifest → Deploy via kubectl

---

## 🛡️ Production Best Practices Implemented

- Non-root container execution
- Read-only filesystem
- Resource requests & limits
- Liveness & readiness probes
- CI security scanning (Trivy)
- Immutable image tagging (SHA-based)
- Automated manifest updates

---

## 🧠 Design Decisions

- FastAPI (Python) → lightweight & fast development
- Docker slim image → reduced attack surface
- Terraform modules → reusable and maintainable IaC
- Terraform state is extended to S3 backend
- ClusterIP service → aligns with requirement
- GitHub Actions → simple and powerful CI/CD

---

## ⚠️ Notes

- No secrets are stored in the repository
- Docker image must be public for Kubernetes to pull
- Logging can be extended using Fluent Bit → CloudWatch

---

## 🌟 Possible Improvements

- Helm-based deployment
- GitOps (ArgoCD / FluxCD)
- Centralized logging (CloudWatch / Loki)
- Ingress for external access

---

## 👨‍💻 Author

Sai Kumar  
DevOps Engineer | AWS | Kubernetes | Terraform

---

## ✅ Summary

This project demonstrates a production-aligned DevOps workflow:

Build → Test → Secure → Deploy → Scale

It highlights automation, security, and cloud-native best practices.