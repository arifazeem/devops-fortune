# Fortune API Deployment

This document outlines the steps to containerize, set up a runtime, and deploy the Fortune API application using AWS EKS with Terraform.

## Prerequisites

Ensure the following tools are configured on your local machine:

- Docker
- AWS CLI
- Terraform
- kubectl

## Steps

### 1. Containerization

#### Containerize the Application

1. **Clone the Repository**

   ```bash
   git clone https://github.com/arifazeem/devops-fortune.git
   cd devops-fortune

2. **Build the Docker Image**

   ```bash
   docker build -t devops-fortune .
   Push Docker Image to ECR

sh
Copy code
aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com
docker tag fortune-api:latest your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest
docker push your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest

