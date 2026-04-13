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
* Helm deployment via Terraform
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
