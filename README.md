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
   -------------------------------------------------------
   verification: 

   ls devops-fortune
   cd devops-fortune

2. **Build the Docker Image**
   
   ```bash
   -------------------------------------------------------
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

####   Deploy AWS EKS Using Terraform
The Terrform script will create VPC with 4 subnets.
2 Subnets will be private and 2 subnets will be public.
In Private subnet EKS cluster and worker node will be created.
In public Subnet Bastion VM will be created though which
we will be accessing EKS cluster. Other resoucres that will be created with this terraform are bastion vm, natgateway, Internet gateway security group,Iam Policy and roles.
Please follow the below digram for better understing

Initialize and Apply Terraform Configuration     
      
     1. cd terraform
     2. terraform init
     3. terraform apply

![alt text](image.png)


### 3. **Deploy the Application**

   #### **Configure Bation VM from where we deploy the kubernetes deployment manifest file**
      
1. #### Confgiure AWS Credentials on bastion vm
      
   1) **Create IAM users [Click here to access the AWS IAM Console](https://us-east-1.console.aws.amazon.com/iamv2/home?region=ap-south-1#/users) and configure awscli Credentials**

      ```bash
      Create IAM user
      - Go to IAM Console and Create One user with least privelidges having access to the AWS Services
      - Once done, please Create access key by clicking access key button.
      - login to Bastion vm and type the command `AWS Configure`
         ssh <bastion-vm>
         ubuntu@ip-10-0-4-171:~$ aws configure
         AWS Access Key ID [****************JTX2]:
         AWS Secret Access Key [****************XCUj]:
         Default region name [ap-south-]: ap-south-1
         Default output format [json]:      

      - Once you setup the credential, you are ready to access the EKS cluster
        
      
   3)  **Add K8s cluster context in ~/.kube/config file to access eks cluster from bation vm**
     
       Run the below command into your terminal to Configure your Bastion vm to establlish communication with K8s Cluster
       ```bash
       aws eks update-kubeconfig --region ap-south-1 --name private_eks_cluster

       Test your configuration.
       
       kubectl cluster-info

       Output should be as below:
       Kubernetes control plane is running at https://://***************************..gr7.ap-south-1.eks.amazonaws.com
       CoreDNS is running at https://***************************.gr7.ap-south-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

   4) **update the aws-auth configmap to access the eks cluster by using instance profile**
      
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


    5)  **Test your configuration**
       
        
         Once done, you run the below commands to test if your cluster is successfully running
   
         Test your configuration
        
         ```bash
         aws sts get-caller-identity
         Output should be as below:
         
         {
          "UserId": "***********MPUJDP",
          "Account": "**********",
          "Arn": "arn:aws:iam::**********:user/arifazim"}

  
    5)  **remove aws keys and check eks cluster are able to access via role**
     
      ```bash
       rm -rf ~/.aws/credentials
       aws sts get-caller-identity
         Output should be as below:
         
         {
         "UserId": "****************:i-08ee4bfb1fee5ca0d",
          "Account": "*************",
          "Arn": "arn:aws:sts::*************:assumed-role/bastion-role/i-08ee4bfb1fee5ca0d"}


  6)  **deploy the application**

      ```bash
      git clone https://github.com/arifazeem/devops-fortune.git
      cd devops-fortune/kubernetes-menifest
      kubectl apply -f .

      
      Accessing the Application
      The application will be accessible via the Load Balancer URL created by the Kubernetes service.
      ```bash
      kubectl get svc


# **Non-Functional Requirements** 
Scalability
Ensure the API can handle a large number of requests by configuring Horizontal Pod Autoscaler (HPA) and deploying it across multiple nodes.

High Availability
Deploy the application across multiple Availability Zones to ensure high availability and fault tolerance.

Security
Use private subnets for deploying the EKS cluster and ensure that the API endpoints are secured using appropriate IAM roles and policies.

Observabilty:
   Apllication:

   Infra:

Success Metrics

![image](https://github.com/user-attachments/assets/f90580ca-0fe5-4926-bd72-4b178d160bc0)


incident managemnet(SLA, SLO's),

