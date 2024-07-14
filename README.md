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
   we will push Push Docker Image to ECR once we create ECR repository via terraform script
   
3. **Push Docker Image to ECR**

   ```bash
   aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com
   docker tag fortune-api:latest your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest
   docker push your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest

### 2. Setup a Runtime
For this guide, we'll use AWS EKS.

####   Deploy Using Terraform
The Terrform script will create VPC with 4 subnets. 2 Subnets will be private and 2 subnets will be public.
In Private subnet EKS cluster and worker node will be created. In public Subnet Bastion VM will be created though which
we will be accessing EKS cluster. Other resoucres that will be created with this terraform are bastion vm, natgateway, Internet gateway security group. Please follow the below digram for better understing

Initialize and Apply Terraform Configuration     
      
      cd terraform
      terraform init
      terraform apply

![alt text](image.png)

sh
Copy code
aws eks --region your-region update-kubeconfig --name eks-cluster


### 3. **Deploy the Application**

   #### **Configure Bation VM**
      
1. #### Confgiure AWS Credentials on bastion vm
      
   1) **Dowload Access Credentials [Click here to access the AWS IAM Console](https://us-east-1.console.aws.amazon.com/iamv2/home?region=ap-south-1#/users) and configure awscli**
      
      ```bash
      aws confgiure
      
   2)  **Dowload kubeconfig file of the cluster**
       ```bash
       aws eks update-kubeconfig --region ap-south-1 --name private_eks_cluster

  3) **update the aws-auth configmap to access the eks cluster from bastion vmi**
      
      ```bash
      kubectl edit cm aws-auth -n kube-system

      
         **add the below data to aws-auth cm**
            ```bash
             data:
              mapRoles: |
                - groups:
                  - system:bootstrappers
                  - system:nodes
                  rolearn: arn:aws:iam::590183814659:role/eks-node-role
                  username: system:node:{{EC2PrivateDNSName}}
                - groups:
                  - system:masters
                  rolearn: arn:aws:iam::590183814659:role/<role_name>
                  username: <role_name>
              mapUsers: |
                - userarn: arn:aws:iam::590183814659:user/<username>
                  username: <username>
                  groups:
                    - system:masters


       role_name: whcih has been attach to the Bation VM
      username: IAM user to which you want to give access to eks cluster


   4)  **Dowload kubeconfig file of the cluster**
       ```bash
       aws eks update-kubeconfig --region ap-south-1 --name private_eks_cluster
  
   5)  **update the aws-auth configmap to access the eks cluster from bastion vm**
     
      ```bash
       kubectl edit cm aws-auth -n kube-system
**add the below data to aws-auth cm**
      ```bash
       data:
        mapRoles: |
          - groups:
            - system:bootstrappers
            - system:nodes
            rolearn: arn:aws:iam::590183814659:role/eks-node-role
            username: system:node:{{EC2PrivateDNSName}}
          - groups:
            - system:masters
            rolearn: arn:aws:iam::590183814659:role/<role_name>
            username: <role_name>
        mapUsers: |
          - userarn: arn:aws:iam::590183814659:user/<username>
            username: <username>
            groups:
              - system:masters

      role_name: whcih has been attach to the Bation VM
      username: IAM user to which you want to give access to eks cluster



   3)  **update the aws-auth configmap to access the eks cluster from bastion vm**
     
      ```bash
       kubectl get cm aws-auth -n kube-system -o yaml > aws-auth.yaml

   3)  **update the aws-auth configmap to access the eks cluster from bastion vm**
     
      ```bash
       kubectl get cm aws-auth -n kube-system -o yaml > aws-auth.yaml

      

Deploy Kubernetes Resources

kubectl apply -f k8s_deployment.yaml
kubectl apply -f k8s_service.yaml
Accessing the Application
The application will be accessible via the Load Balancer URL created by the Kubernetes service.

