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

- `screenshots/VPC/` for VPC, subnets, route tables, and networking
- `screenshots/SG/` for security group configuration
- `screenshots/EC2 & ASG/` for EC2 instances and Auto Scaling
- `screenshots/Launch template/` for launch template setup
- `screenshots/Load Balancer/` for ALB and target groups
- `screenshots/Teminal/` for terminal-based validation

## Outcome

This project demonstrates how to build a secure and scalable AWS web architecture where the application tier stays private, administration is handled through a bastion host, and internet traffic is controlled through a load balancer.

## Author

Prateek Kulkarni
