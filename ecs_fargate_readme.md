# ECS Fargate Cloud-Native Microservice Platform

## 📌 Overview
This project demonstrates a **production-style cloud-native backend** deployed on **AWS ECS Fargate**, using **Infrastructure as Code (Terraform)** and **CI/CD automation**.

The focus of this project is **DevOps and cloud architecture**, not backend complexity.  
The application is intentionally simple to highlight **container orchestration, automation, security, and observability** using AWS-managed services — without managing EC2 instances directly.

---

## 🎯 Objectives
- Deploy containers without server management using **ECS Fargate**
- Automate infrastructure provisioning with **Terraform**
- Implement **CI/CD pipelines** for containerized workloads
- Apply **least-privilege IAM** and secure secret handling
- Enable centralized **logging and monitoring**
- Design a scalable and production-ready AWS architecture

---

## 🏗 High-Level Architecture

```
GitHub → GitHub Actions → Amazon ECR
                           ↓
                    ECS Fargate Service
                           ↓
                  Application Load Balancer
                           ↓
                      Node.js REST API
                           ↓
                      DynamoDB (managed)
```

📌 ECS tasks run in **private subnets**, while the ALB is exposed publicly.

---

## 🧰 Technology Stack

### Cloud & Infrastructure
- AWS ECS (Fargate launch type)
- Application Load Balancer (ALB)
- Amazon ECR
- DynamoDB
- IAM (task & execution roles)
- CloudWatch Logs & Metrics
- Terraform

### DevOps & Automation
- Docker
- GitHub Actions (CI/CD)
- Infrastructure as Code (IaC)
- Rolling deployments

### Application
- Node.js
- Express.js
- REST API

---

## 📁 Repository Structure

```
ecs-fargate-microservice-platform/
├── app/                  # Application source code
├── terraform/            # Infrastructure as Code
├── .github/workflows/    # CI/CD pipeline
├── diagrams/             # Architecture diagrams
├── scripts/              # Helper scripts
└── README.md
```

---

## 🚀 Application Features

- RESTful API endpoints
- Health check endpoint for ALB and ECS
- Stateless design (cloud-native)
- Containerized using Docker

### Example Endpoints
```
GET    /health
POST   /users
GET    /users
POST   /tasks
GET    /tasks
```

---

## 🔄 CI/CD Pipeline

1. Code pushed to GitHub
2. GitHub Actions pipeline:
   - Installs dependencies
   - Builds Docker image
   - Pushes image to Amazon ECR
   - Updates ECS service
3. ECS performs rolling deployment
4. Application becomes available via ALB

---

## 🔐 Security Practices

- No hard-coded credentials
- IAM roles for ECS tasks (least privilege)
- Containers run in private subnets
- Security groups restrict traffic flow
- Secrets stored securely (AWS-native approach)

---

## 📊 Observability & Monitoring

- Application logs streamed to **CloudWatch Logs**
- ECS metrics monitored:
  - CPU utilization
  - Memory usage
- ALB health checks ensure service availability

---

## 🧪 Local Development

### Run locally with Docker
```bash
cd app
npm install
docker build -t ecs-fargate-app .
docker run -p 3000:3000 ecs-fargate-app
```

### Test API
```bash
curl http://localhost:3000/health
```

---

## 🌍 Infrastructure Deployment

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

After deployment, Terraform outputs the **ALB DNS name** to access the service.

---

## 📈 What This Project Demonstrates

- Cloud-native container orchestration
- ECS Fargate without EC2 management
- Infrastructure automation with Terraform
- CI/CD best practices
- Secure and scalable AWS architecture
- Production-oriented DevOps mindset

---

## 🧠 Design Decisions

- **Fargate over EC2**: Eliminates server management overhead
- **ALB + IP target groups**: Native ECS integration
- **Terraform**: Reproducible, version-controlled infrastructure
- **Stateless API**: Enables easy scaling and resilience

---

## 🔮 Future Improvements

- Auto-scaling policies for ECS service
- Blue/green deployments with CodeDeploy
- Distributed tracing with AWS X-Ray
- Cost monitoring and budget alerts
- Authentication with Amazon Cognito

---

## 👤 Author
**Gerald Ugwunna**  
Cloud / DevOps Engineer (Entry-Level)  
Focus: AWS, Terraform, CI/CD, Containers

