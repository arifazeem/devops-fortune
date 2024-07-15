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

   #### Note: run this steps once ECR got Created after running the terraform script.

   ```bash
   aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com
   docker tag fortune-api:latest your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest
   docker push your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest

### 2. Setup a Runtime
For this guide, we'll use AWS EKS.

####   Deploy Using Terraform
The Terrform script will create VPC with 4 subnets. 2 Subnets will be private and 2 subnets will be public.
In Private subnet EKS cluster and worker node will be created. In public Subnet Bastion VM will be created though which
we will be accessing EKS cluster. Other resoucres that will be created with this terraform are bastion vm, natgateway, Internet gateway security group,Iam Policy and roles. Please follow the below digram for better understing

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
      
   1) **Create IAM users [Click here to access the AWS IAM Console](https://us-east-1.console.aws.amazon.com/iamv2/home?region=ap-south-1#/users) and configure awscli Credentials**

      ```bash
      Create IAM user
      - Go to IAM Console and Create One user having access to the AWS Services
      - Once done, please Create access key
      - login to Bastion vm and type the command `AWS Configure`
      - Once you setup the credential, you are ready to access the EKS cluster
        
      
   3)  **Add K8s cluster context in ~/.kube/config file to access eks cluster from bation vm**
     
       Run the below command into your terminal to Configure your Bastion vm to establlish communication with K8s Cluster
       ```bash
       aws eks update-kubeconfig --region ap-south-1 --name private_eks_cluster

   4) **update the aws-auth configmap to access the eks cluster from bastion vm using instance profile**
      
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


    5)  **Dowload kubeconfig file of the cluster  Add the K8s cluster context in ~/.kube/config file**
       
        
         Once done, you run the below commands to test if your cluster is successfully running
   
         Test your configuration
        
         ```bash
         kubectl get svc
         Output should be as below:
         
         NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
         svc/kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   1m

  
    5)  **remove aws keys and check eks cluster are able to access via role**
     
      ```bash
       rm -rf .aws
       aws sts get-caller-identity
  6)  **deploy the application**

      ```bash
      git clone https://github.com/arifazeem/devops-fortune.git
      cd devops-fortune/devops-fortune-api
      kubectl apply -f .

      
Accessing the Application
The application will be accessible via the Load Balancer URL created by the Kubernetes service.
```bash
kubectl get svc

