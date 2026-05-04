# AWS VPC Project

This project documents a production-style AWS network and web-tier setup using a custom VPC, public and private subnets, a bastion host, private Nginx instances, an Auto Scaling Group, and an Application Load Balancer.

## Architecture Overview

- Custom VPC with CIDR `10.0.0.0/16`
- Public subnets for internet-facing components
- Private subnets for application instances
- Internet Gateway for public access
- NAT Gateway for outbound access from private instances
- Bastion host for secure SSH access
- Nginx web servers deployed on private EC2 instances
- Auto Scaling Group for availability and scaling
- Application Load Balancer for traffic distribution

## Services Used

- AWS VPC
- AWS EC2
- AWS Auto Scaling
- AWS Application Load Balancer
- AWS Security Groups
- NAT Gateway
- Internet Gateway

## Project Structure

```text
aws-vpc-project/
|-- README.md
|-- scripts/
|   `-- nginx-install.sh
`-- screenshots/
    |-- README.md
    |-- EC2 & ASG/
    |-- Launch template/
    |-- Load Balancer/
    |-- SG/
    |-- Teminal/
    `-- VPC/
```

## Infrastructure Highlights

### VPC and Subnets

- VPC CIDR: `10.0.0.0/16`
- Public subnets for bastion host, NAT Gateway, and ALB
- Private subnets for Nginx application instances

### Security Design

- Bastion host accepts SSH only from an allowed source IP
- Private instances do not require public IPs
- ALB forwards HTTP traffic to private Nginx instances
- Security groups restrict access between tiers

### Compute and Scaling

- Bastion host used as the secure jump server
- Nginx instances launched in private subnets
- Auto Scaling Group maintains healthy web instances
- Application Load Balancer distributes incoming traffic

## Nginx Bootstrap Script

The project includes a simple user-data style installation script:

```bash
#!/bin/bash
sudo apt update && sudo apt install nginx unzip wget -y

cd /tmp
wget -O 2106_soft_landing.zip https://www.tooplate.com/download/2106_soft_landing.zip
unzip 2106_soft_landing.zip
cp -r 2106_soft_landing/* /var/www/html/

systemctl start nginx
systemctl enable nginx
```

Script location: [scripts/nginx-install.sh](scripts/nginx-install.sh)

## Access Flow

1. Users access the application through the Application Load Balancer.
2. The ALB routes traffic to Nginx instances in private subnets.
3. Administrators connect to the bastion host first.
4. From the bastion host, administrators SSH into private instances.

## Screenshots

The repository includes screenshots for each major setup stage:

-  VPC  
  <img width="1878" height="874" alt="image" src="https://github.com/user-attachments/assets/e87c1175-61e8-4eec-98da-2b6f1d299c81" />

-  Subnets
  <img width="1886" height="862" alt="image" src="https://github.com/user-attachments/assets/cb4e56c4-ae6f-4b84-86e1-4ac466db926a" />

-  Route tables
   <img width="1907" height="872" alt="image" src="https://github.com/user-attachments/assets/864c7ad1-8970-40b5-b8f8-761c910e8a06" />

-  Networking
  <img width="1900" height="872" alt="image" src="https://github.com/user-attachments/assets/b30c1f42-0911-4f07-8efc-013171b706b5" />
  

-  Security groups
  
-  Bastion-Sg
  <img width="1907" height="868" alt="image" src="https://github.com/user-attachments/assets/c8613799-c4c0-48e3-8900-c443eb7e8596" />

-  Alb-Sg
  <img width="1890" height="870" alt="image" src="https://github.com/user-attachments/assets/53db4e88-e143-4e2f-9024-6c5f2e33febd" />

-  Private instance-Sg
- <img width="1911" height="877" alt="image" src="https://github.com/user-attachments/assets/62f1be16-88c4-4d6d-95c9-7926f5815fa1" />

-  Configuration
  <img width="1876" height="723" alt="image" src="https://github.com/user-attachments/assets/e2f35b54-e6d1-4433-8ab7-cb15bfb30890" />


-  EC2 instances 
  <img width="1896" height="870" alt="image" src="https://github.com/user-attachments/assets/89692170-1c43-44e4-a09f-6862bd1465e7" />

-   Auto Scaling
  <img width="1895" height="860" alt="image" src="https://github.com/user-attachments/assets/48edd693-41bc-4875-a3bd-7b9ccc467709" />

-  Auto Scaling instances
  <img width="1886" height="872" alt="image" src="https://github.com/user-attachments/assets/a7b21f7d-c31b-4977-907e-1c82ade667cf" />

-  Launch template setup
  <img width="1895" height="881" alt="image" src="https://github.com/user-attachments/assets/4eadc803-e6be-49e6-9a77-c45426d3bcc6" />

-  ALB and target groups
  <img width="1912" height="873" alt="image" src="https://github.com/user-attachments/assets/5918b487-9fb5-4c7b-8449-0bdda3dd3b55" />
 
  <img width="1918" height="877" alt="image" src="https://github.com/user-attachments/assets/c122dd24-0cc6-4a9f-8150-e6766d0e72a6" />

-  Terminal
   <img width="1887" height="960" alt="image" src="https://github.com/user-attachments/assets/de2a7f5d-3670-4383-9b04-68097b9682af" />


## Outcome

This project demonstrates how to build a secure and scalable AWS web architecture where the application tier stays private, administration is handled through a bastion host, and internet traffic is controlled through a load balancer.

## Author

Prateek Kulkarni

⭐ If you like this project
