To accomplish the tasks outlined, we'll follow these steps:



1.    Containerization:

      Containerize the application from the provided GitHub repository.
      Push the Docker image to Docker Hub or AWS ECR.
      

2.    Setup a Runtime:

      Choose a stack (AWS ECS, AWS EKS, or Lambda) for running the application.
      Manage the setup using Infrastructure as Code (IaC) tools like Terraform, CloudFormation, Pulumi, or Serverless framework.

3.    Deploy the Application:

      Deploy the application using the chosen stack.
      Document the setup and deployment instructions.


Let's break this down step-by-step:

![alt text](image.png)


### Prerequisites that you have to configired on you local 
- Docker
- AWS CLI
- Terraform
- kubectl

### Steps

1.    Containerization:

      a). **Clone the repository**:
         ```sh
         git clone https://github.com/arifazeem/devops-fortune.git
         cd devops-fortune


      **b). **Build the docker images**:**
         ```sh
         git clone https://github.com/arifazeem/devops-fortune.git
         cd devops-fortune
         
      


1. **Deploy using Terraform:
   ```sh
      cd terraform
      terraform init
      terraform apply
      Configure kubectl:
   

2. **Build and push Docker image and push to ECR:
   ```sh
      aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com
      docker tag fortune-api:latest your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest
      docker push your-account-id.dkr.ecr.your-region.`amazonaws.com/fortune-api:latest

3. Login to bastion VM that got created using Terraform 
   
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
