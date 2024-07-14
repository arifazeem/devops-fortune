Documentation and Granting Access
Document your setup and deployment instructions in a README.md file within your repository:

![alt text](image.png)

markdown
Copy code
## Fortune API Deployment

### Prerequisites
- Docker
- AWS CLI
- Terraform
- kubectl

### Steps

1. **Clone the repository**:
   ```sh
   git clone https://github.com/wego/devops-fortune-api.git
   cd devops-fortune-api

2. **Build and push Docker image and push to ECR:
   ```sh
      aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com
      docker tag fortune-api:latest your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest
      docker push your-account-id.dkr.ecr.your-region.`amazonaws.com/fortune-api:latest

3. **Deploy using Terraform:
   ```sh
      terraform init
      terraform apply
      Configure kubectl:

4.
sh
Copy code
aws eks --region your-region update-kubeconfig --name eks-cluster
Deploy Kubernetes resources:

sh
Copy code
kubectl apply -f k8s_deployment.yaml
kubectl apply -f k8s_service.yaml
Accessing the Application
The application will be accessible via the Load Balancer URL created by the Kubernetes service.
Copy code
Grant read access to the Git repository containing your IaC files by inviting the appropriate GitHub usernames as collaborators.

By following these steps, you should have a fully containerized and deployed application running on AWS EKS, managed by Terraform.