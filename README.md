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
   -------------------------------------------------------
   we will push Push Docker Image to ECR once we create ECR repository via terraform script
   
3. **Push Docker Image to ECR**

   #### Note: run this steps once ECR got Created after running the terraform script.

   ```bash
   -------------------------------------------------------
   aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com
   docker tag fortune-api:latest your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest
   docker push your-account-id.dkr.ecr.your-region.amazonaws.com/fortune-api:latest
   -------------------------------------------------------

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
-------------------------------------------------------
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
      -------------------------------------------------------
      kubectl edit cm aws-auth -n kube-system
      -------------------------------------------------------
    
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
         -------------------------------------------------------
         aws sts get-caller-identity
         -------------------------------------------------------

         Output should be as below:
         
         {
          "UserId": "***********MPUJDP",
          "Account": "**********",
          "Arn": "arn:aws:iam::**********:user/arifazim"}

  
    5)  **remove aws keys and check eks cluster are able to access via role**
     
      ```bash
      -------------------------------------------------------
       rm -rf ~/.aws/credentials
       aws sts get-caller-identity
      -------------------------------------------------------

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

      kubectl get svc

      below are the output
      ---------------------------------------------------------------------------------------------------------------------------------------------------
      NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP                                                                PORT(S)          AGE
      fotune-api-service   LoadBalancer   172.20.254.44   a4489e945842f44369cca5c0c842db21-1620078989.ap-south-1.elb.amazonaws.com   8080:30914/TCP   24s
      ----------------------------------------------------------------------------------------------------------------------------------------------------

      use a4489e945842f44369cca5c0c842db21-1620078989.ap-south-1.elb.amazonaws.com:8080/healthcheck
      ----------------------------------------------------------------------------------------------------------------------------------------------------

# **Non-Functional Requirements** 
### **Deployment**
   Out of Blue-Green, Canary Release, we would go for Canary release as the partners would be migrated in phases and the % of infra allocated depends on the % of partners migrated to the new Stream based system
 

The build files will have the config files and runtime args to deploy in any region with a single click.
Rollout of modules will be done based on their criticality and dependency
![image](https://github.com/user-attachments/assets/75c0e3a9-bce3-4316-a197-e1ed7da463a0)

### **Scalability**
   Ensure the API can handle a large number of requests by configuring Horizontal Pod Autoscaler (HPA) and deploying it across multiple nodes.

### **High Availability**
   Deploy the application across multiple Availability Zones to ensure high availability and fault tolerance.

### **Fault Tolerance**
   Being a distributed system, the system is designed such that unhealthy pods can go down, can be removed from traffic by the Gateway, the zone or region can go unavailable for some time.
### **Security**
   Use private subnets for deploying the EKS cluster and ensure that the API endpoints are secured using appropriate IAM roles and policies.

### **Observabilty:**
      Apllication:

      Infra:

### **Success Metrics**

# Metrics Overview

| Sno | Metric                                | Details                                                                                                                                                          |
|-----|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1   | MMTR and MMTD                         | The Observability tool should have minimum time to detect an issue from logs and application metrics and should have a mechanism to auto-heal or generate an incident ticket. |
| 2   | Infrastructure cost optimization      | Proper data retention policies, profiling of the platform at each layer will help in optimal utilization of Infra, thereby bringing down the cost per transaction.        |
| 3   | Support incidents                     | A reduction in support incidents month over month post-migration is a metric to measure the support costs.                                                          |
| 4   | Time to enhance a feature or add a feature | Adaptability and extensibility of this stream-based platform will reduce the time to develop/enhance feature requests.                                             |
| 5   | Support cost on onboarding            | The interface should be a self-service UI to onboard partners / merchants, and the number of onboarding support issues should be minimal.                            |


# Dockuments Link

▬▬▬▬▬▬ Important links❗️ ▬▬▬▬▬▬


► [AWS EKS Official Documentation](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html)

► [Kubectl installation Guide](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)



► [Update kubeconfig](https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html)

►  [Enabling IAM principal access to your cluster](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html#creating-access-entries)


