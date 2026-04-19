# AWS Production VPC Architecture

A production-level AWS infrastructure project featuring a secure VPC setup with public and private subnets, Bastion Host for secure SSH access, Nginx web server on private instances, Auto Scaling Group for high availability, and an Application Load Balancer for traffic distribution.

---

## Architecture Overview

```
Internet
    |
Internet Gateway (IGW)
    |
+------------------VPC (10.0.0.0/16)------------------+
|                                                       |
|  +-- Public Subnets --+    +-- Private Subnets --+   |
|  |                    |    |                      |   |
|  |  Bastion Host      |    |  Nginx EC2 (ASG-1)   |   |
|  |  (Jump Server)  ---|SSH-|->                    |   |
|  |                    |    |  Nginx EC2 (ASG-2)   |   |
|  |  NAT Gateway       |    |                      |   |
|  |                    |    +----------------------+   |
|  +--------------------+             |                 |
|          |                     (outbound only)        |
|    Public Route Table        Private Route Table      |
|    0.0.0.0/0 → IGW          0.0.0.0/0 → NAT GW       |
+-------------------------------------------------------+
    |
Application Load Balancer (ALB)
    |
  Users (Internet)
```

---

## Tech Stack

| Service | Purpose |
|---------|---------|
| AWS VPC | Isolated network environment |
| EC2 | Virtual machines for Bastion and Nginx |
| Auto Scaling Group | Automatic scaling of Nginx instances |
| Application Load Balancer | Distribute traffic across Nginx instances |
| NAT Gateway | Outbound internet for private instances |
| Internet Gateway | Inbound/outbound internet for public subnet |
| Security Groups | Firewall rules for each resource |

---

## Project Structure

```
aws-vpc-project/
│
├── screenshots/
│   ├── vpc/
│   │   ├── 01-vpc.png
│   │   ├── 02-subnets.png
│   │   ├── 03-internet-gateway.png
│   │   ├── 04-nat-gateway.png
│   │   ├── 05-route-tables.png
│   │   ├── 06-public-rt-routes.png
│   │   ├── 07-private-rt-routes.png
│   │   ├── 08-public-rt-associations.png
│   │   └── 09-private-rt-associations.png
│   │
│   ├── security-groups/
│   │   ├── 10-sg-bastion-inbound.png
│   │   ├── 11-sg-alb-inbound.png
│   │   ├── 12-sg-alb-outbound.png
│   │   └── 13-sg-nginx-inbound.png
│   │
│   ├── ec2/
│   │   ├── 14-all-instances.png
│   │   ├── 15-bastion-details.png
│   │   └── 16-nginx-instance-details.png
│   │
│   ├── asg/
│   │   ├── 17-launch-template.png
│   │   ├── 18-launch-template-userdata.png
│   │   ├── 19-asg-details.png
│   │   └── 20-asg-instance-management.png
│   │
│   ├── alb/
│   │   ├── 21-load-balancer.png
│   │   └── 22-target-group-healthy.png
│   │
│   └── final/
│       ├── 23-website-running.png
│       └── 24-ssh-bastion-to-private.png
│
├── scripts/
│   └── nginx-install.sh
│
└── README.md
```

---

## Infrastructure Details

### VPC Configuration

| Resource | Value |
|----------|-------|
| VPC CIDR | `10.0.0.0/16` |
| Region | `ap-south-1` (Mumbai) |
| Availability Zones | `ap-south-1c`, `ap-south-1b` |

### Subnets

| Name | CIDR | Type | AZ |
|------|------|------|----|
| prod-public-subnet-1 | `10.0.1.0/24` | Public | ap-south-1c |
| prod-public-subnet-2 | `10.0.2.0/24` | Public | ap-south-1c |
| prod-public-subnet-3 | `10.0.5.0/24` | Public | ap-south-1b |
| prod-private-subnet-1 | `10.0.3.0/24` | Private | ap-south-1c |
| prod-private-subnet-2 | `10.0.4.0/24` | Private | ap-south-1c |

### Route Tables

| Route Table | Subnet Association | Route |
|------------|-------------------|-------|
| prod-public-rt | All public subnets | `0.0.0.0/0` → IGW |
| prod-private-rt | All private subnets | `0.0.0.0/0` → NAT GW |

---

## Security Groups

### Bastion Security Group (`bastion-sg`)

| Direction | Type | Protocol | Port | Source |
|-----------|------|----------|------|--------|
| Inbound | SSH | TCP | 22 | Your IP `/32` |
| Outbound | All traffic | All | All | `0.0.0.0/0` |

### ALB Security Group (`alb-sg`)

| Direction | Type | Protocol | Port | Source |
|-----------|------|----------|------|--------|
| Inbound | HTTP | TCP | 80 | `0.0.0.0/0` |
| Inbound | HTTPS | TCP | 443 | `0.0.0.0/0` |
| Outbound | HTTP | TCP | 80 | `private-sg` |

### Nginx Security Group (`private-sg`)

| Direction | Type | Protocol | Port | Source |
|-----------|------|----------|------|--------|
| Inbound | SSH | TCP | 22 | `bastion-sg` |
| Inbound | HTTP | TCP | 80 | `alb-sg` |
| Outbound | All traffic | All | All | `0.0.0.0/0` |

---

## EC2 Instances

| Instance | Type | Subnet | Public IP | Security Group |
|----------|------|--------|-----------|----------------|
| Bastion | t3.micro | Public | Yes | bastion-sg |
| ASG-1 (Nginx) | t3.micro | Private | No | private-sg |
| ASG-2 (Nginx) | t3.micro | Private | No | private-sg |

---

## Auto Scaling Group

| Setting | Value |
|---------|-------|
| Name | prod-nginx-asg |
| Launch Template | prod-nginx-lt |
| Desired Capacity | 2 |
| Minimum Capacity | 1 |
| Maximum Capacity | 4 |
| Scaling Policy | Target CPU 60% |
| Target Group | prod-nginx-tg |

---

## Nginx Install Script

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

---

## How to SSH into Private Instance

### Prerequisites
- Bastion `.pem` key file
- Nginx instance `.pem` key file

### Step 1 — Copy Nginx key to Bastion

```bash
scp -i "bastion-key.pem" nginx-key.pem ubuntu@<BASTION_PUBLIC_IP>:~/nginx-key.pem
```

### Step 2 — SSH into Bastion

```bash
ssh -i "bastion-key.pem" ubuntu@<BASTION_PUBLIC_IP>
```

### Step 3 — Set permissions and SSH into private instance

```bash
chmod 400 nginx-key.pem
ssh -i "nginx-key.pem" ubuntu@<PRIVATE_INSTANCE_IP>
```

### Or use SSH ProxyJump (one command)

```bash
ssh -J ubuntu@<BASTION_PUBLIC_IP> ubuntu@<PRIVATE_INSTANCE_IP> -i nginx-key.pem
```

---

## How to Test the Setup

1. Go to **EC2 → Load Balancers → prod-alb**
2. Copy the **DNS name**
3. Open in browser:

```
http://prod-alb-xxxxx.ap-south-1.elb.amazonaws.com
```

You should see the Nginx website running.

---

## Key Concepts Demonstrated

- **Network Isolation** — Private instances have no public IP and are not directly accessible from internet
- **Bastion Host Pattern** — Secure SSH access to private instances via a jump server
- **NAT Gateway** — Allows private instances to reach internet for updates without exposing them
- **Security Group Chaining** — ALB → Nginx → Bastion using SG references instead of IP ranges
- **Auto Scaling** — ASG automatically maintains desired number of healthy instances
- **Load Balancing** — ALB distributes traffic across multiple Nginx instances
- **High Availability** — Resources spread across multiple Availability Zones

---

## Screenshots

### VPC
![VPC](screenshots/vpc/01-vpc.png)
![Subnets](screenshots/vpc/02-subnets.png)
![Internet Gateway](screenshots/vpc/03-internet-gateway.png)
![NAT Gateway](screenshots/vpc/04-nat-gateway.png)
![Route Tables](screenshots/vpc/05-route-tables.png)
![Public RT Routes](screenshots/vpc/06-public-rt-routes.png)
![Private RT Routes](screenshots/vpc/07-private-rt-routes.png)

### Security Groups
![Bastion SG](screenshots/security-groups/10-sg-bastion-inbound.png)
![ALB SG](screenshots/security-groups/11-sg-alb-inbound.png)
![Nginx SG](screenshots/security-groups/13-sg-nginx-inbound.png)

### EC2 Instances
![All Instances](screenshots/ec2/14-all-instances.png)
![Bastion Details](screenshots/ec2/15-bastion-details.png)

### Auto Scaling
![Launch Template](screenshots/asg/17-launch-template.png)
![ASG Details](screenshots/asg/19-asg-details.png)

### Load Balancer
![ALB](screenshots/alb/21-load-balancer.png)
![Target Group Healthy](screenshots/alb/22-target-group-healthy.png)

### Final Result
![Website Running](screenshots/final/23-website-running.png)
![SSH via Bastion](screenshots/final/24-ssh-bastion-to-private.png)

---

## Author

**Prateek Putta**  
AWS Cloud Infrastructure Project  
April 2026
