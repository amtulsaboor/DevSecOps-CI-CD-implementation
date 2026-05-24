# End-to-End DevSecOps CI/CD Pipeline for Django Application on AWS EKS
<img width="1536" height="1024" alt="ChatGPT Image May 24, 2026, 12_37_42 PM" src="https://github.com/user-attachments/assets/4b078d83-7b26-46d4-ab13-f260778ed5ce" />


## Project Overview

This project demonstrates a complete **DevSecOps CI/CD pipeline** for deploying a **Django application** using modern DevOps tools and practices.

The pipeline includes:

* Infrastructure provisioning using Terraform
* Source code management with GitHub
* Continuous Integration using Jenkins
* Code Quality Analysis using SonarQube
* Containerization with Docker
* Vulnerability Scanning using Trivy
* Image Storage using DockerHub
* Continuous Deployment using ArgoCD
* Kubernetes Deployment on AWS EKS
* Notifications using Slack

---

# Tech Stack Used

| Tool       | Purpose                      |
| ---------- | ---------------------------- |
| GitHub     | Source Code Repository       |
| Terraform  | Infrastructure as Code       |
| AWS EC2    | Jenkins & SonarQube Server   |
| Jenkins    | CI/CD Automation             |
| SonarQube  | Static Code Analysis         |
| Docker     | Containerization             |
| DockerHub  | Docker Image Registry        |
| Trivy      | Image Vulnerability Scanning |
| Kubernetes | Container Orchestration      |
| AWS EKS    | Managed Kubernetes Cluster   |
| ArgoCD     | GitOps Deployment            |
| Slack      | Notifications                |
| Vault      | Secrets Management           |

---

# Project Workflow

1. Developer pushes Django code to GitHub.
2. GitHub Webhook triggers Jenkins CI pipeline.
3. Jenkins pulls source code.
4. SonarQube performs static code analysis.
5. Jenkins builds Docker image.
6. Trivy scans Docker image for vulnerabilities.
7. Docker image is pushed to DockerHub.
8. Jenkins updates Kubernetes manifest files.
9. ArgoCD detects changes in Git repository.
10. ArgoCD deploys application to EKS Cluster.
11. Slack sends deployment notifications.

---

# AWS Infrastructure Setup

## Step 1: Launch EC2 Instance

Launch Ubuntu EC2 instance:

| Configuration        | Value                |
| -------------------- | -------------------- |
| AMI                  | Ubuntu 22.04         |
| Instance Type        | t2.xlarge            |
| Storage              | 30 GB                |
| Security Group Ports | 22, 8080, 9000, 3000 |

---

## Step 2: Connect to EC2

```bash
ssh -i your-key.pem ubuntu@<PUBLIC-IP>
```
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 1 42 56 PM" src="https://github.com/user-attachments/assets/ceebd9b3-c7e7-4215-a857-63ea74083321" />

---

# Install Java

```bash
sudo apt update -y
sudo apt install openjdk-21-jdk -y
java -version
```

---

# Install Jenkins

## Add Jenkins Repository

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins
```

## Start Jenkins

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

---

# Access Jenkins

```bash
http://<PUBLIC-IP>:8080
```

Get Jenkins password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 1 55 34 PM" src="https://github.com/user-attachments/assets/cbef77a5-bbaf-4f31-8b0b-36e32fe06160" />

---

# Install Docker

```bash
sudo apt install docker.io -y
```

```bash
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
```

```bash
sudo chmod 777 /var/run/docker.sock
```

Restart instance once:

```bash
sudo reboot
```

---

# Install SonarQube using Docker

```bash
docker run -d --name sonarqube \
-p 9000:9000 sonarqube:lts-community
```

Access:

```bash
http://<PUBLIC-IP>:9000
```

Default Credentials:

```text
Username: admin
Password: admin
```
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 2 24 15 PM" src="https://github.com/user-attachments/assets/fee8c70c-9e3d-4b8d-83a5-47e74bc2235a" />

---

# Install Trivy

```bash
# 1. Install prerequisites
sudo apt-get update && sudo apt-get install -y wget gnupg lsb-release

# 2. Download and store the key in the secure keyring directory
wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# 3. Add the repository linked directly to that specific key
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list

# 4. Update your package lists and install Trivy
sudo apt-get update && sudo apt-get install -y trivy

```

Verify:

```bash
trivy --version
```

---

# Install AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o "awscliv2.zip"
```

```bash
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
```

Verify:

```bash
aws --version
```

---

# Configure AWS CLI

```bash
aws configure
```

Enter:

```text
AWS Access Key
AWS Secret Key
Region
Output Format
```

---

# Install kubectl

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
```

```bash
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Verify:

```bash
kubectl version --client
```

---

# Install eksctl

```bash
curl --silent --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname \
-s)_amd64.tar.gz" | tar xz -C /tmp
```

```bash
sudo mv /tmp/eksctl /usr/local/bin
```

Verify:

```bash
eksctl version
```

---

# Create EKS Cluster

```bash
eksctl create cluster \
--name devsecops-cluster \
--region ap-south-1 \
--nodegroup-name workers \
--node-type t2.medium \
--nodes 2
```

Check Nodes:

```bash
kubectl get nodes
```

---

# Install ArgoCD

## Create Namespace

```bash
kubectl create namespace argocd
```

## Install ArgoCD

```bash
kubectl apply -n argocd -f \
https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Check Pods

```bash
kubectl get pods -n argocd
```

---

# Expose ArgoCD Server

```bash
kubectl patch svc argocd-server -n argocd \
-p '{"spec": {"type": "LoadBalancer"}}'
```

Get LoadBalancer URL:

```bash
kubectl get svc -n argocd
```

---

# Get ArgoCD Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

---

# Install Terraform

```bash
sudo apt install gnupg software-properties-common -y
```

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```bash
sudo apt update && sudo apt install terraform -y
```

Verify:

```bash
terraform -version
```

---

# Create GitHub Webhook

GitHub Repository → Settings → Webhooks

Payload URL:

```text
http://<JENKINS-PUBLIC-IP>:8080/github-webhook/
```

Content Type:

```text
application/json
```

Events:

```text
Just the push event
```
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 2 51 14 PM" src="https://github.com/user-attachments/assets/0179bc1f-5462-4ad4-9749-e7326aa3d786" />

---

# Jenkins Plugins Required

Install these plugins:

* Docker Pipeline
* Kubernetes
* SonarQube Scanner
* Pipeline
* GitHub Integration
* Slack Notification
* Blue Ocean
* Docker
* Credentials Binding
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 2 46 44 PM" src="https://github.com/user-attachments/assets/6ad03e82-7b0e-4bb0-8742-572e40b96523" />

---

# Configure Jenkins Tools

## JDK

Manage Jenkins → Global Tool Configuration

Add:

```text
JDK17
```

---

## SonarQube Scanner

Add SonarQube Scanner.

Name:

```text
sonar-scanner
```

---

# Add Jenkins Credentials

Add these credentials:

| Credential                  | Type              |
| --------------------------- | ----------------- |
| DockerHub Username/Password | Username Password |
| GitHub Token                | Secret Text       |
| Sonar Token                 | Secret Text       |
| Slack Token                 | Secret Text       |
| AWS Credentials             | AWS Credentials   |
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 3 08 29 PM" src="https://github.com/user-attachments/assets/fb13f142-e02d-49f2-87fa-10397a1b71e7" />
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 2 50 31 PM" src="https://github.com/user-attachments/assets/1f486444-0a0c-4dfa-bdb3-6f5d6db1a1f1" />
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 2 49 28 PM" src="https://github.com/user-attachments/assets/fb0341f2-28f4-4383-8ce4-b17d9982347d" />

---

# Django Application Dockerfile

```dockerfile
FROM python:3.10

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 8000

CMD ["python","manage.py","runserver","0.0.0.0:8000"]
```

---

# Kubernetes Deployment File

## deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: django-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: django-app

  template:
    metadata:
      labels:
        app: django-app

    spec:
      containers:
      - name: django-container
        image: amtulsaboor/django-app:latest

        ports:
        - containerPort: 8000
```

---

# Kubernetes Service File

## service.yaml

```yaml
apiVersion: v1
kind: Service

metadata:
  name: django-service

spec:
  selector:
    app: django-app

  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000

  type: LoadBalancer
```

---


# Configure ArgoCD Application

```bash
argocd login <ARGOCD-SERVER>
```

```bash
argocd app create django-app \
--repo https://github.com/your-repo.git \
--path k8s \
--dest-server https://kubernetes.default.svc \
--dest-namespace default
```

Sync Application:

```bash
argocd app sync django-app
```

---

# Verify Deployment

```bash
kubectl get pods
```

```bash
kubectl get svc
```

```bash
kubectl get deployments
```
<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 4 30 15 PM" src="https://github.com/user-attachments/assets/078aa153-8c25-41ba-8804-d708015b5643" />

<img width="1710" height="1107" alt="Screenshot 2026-05-24 at 5 13 41 PM" src="https://github.com/user-attachments/assets/a3fa21dc-caa1-408b-a2ae-3e28ffb43886" />

---

# Security Best Practices

* Store secrets in Vault
* Use IAM roles instead of access keys
* Enable Trivy vulnerability scanning
* Use HTTPS for Jenkins and SonarQube
* Restrict security group access
* Rotate credentials regularly

---

# Cleanup Resources

## Delete EKS Cluster

```bash
eksctl delete cluster --name devsecops-cluster --region ap-south-1
```

## Terminate EC2 Instance

AWS Console → EC2 → Terminate Instance

---

# Final Output

At the end of the project you will have:

✅ Automated CI/CD Pipeline
✅ Dockerized Django Application
✅ Secure DevSecOps Workflow
✅ Kubernetes Deployment on AWS EKS
✅ GitOps Deployment using ArgoCD
✅ Slack Deployment Notifications
✅ Static Code Analysis & Vulnerability Scanning

---

# Author

## Amtul Saboor

DevOps & Cloud Engineer 
