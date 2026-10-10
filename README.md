# DevOps Automation Project

An end-to-end DevOps CI/CD pipeline: Code is pushed to GitHub (`itsshakirahamed-debug/devops-automation-project`), Jenkins builds a Docker image and pushes it to GitHub Container Registry (GHCR), and Terraform provisions an AWS EC2 server running the interactive containerized web application.

## Architecture

```
Git (local) → GitHub → Jenkins ─┬─ docker build + push → GHCR (ghcr.io)
                                └─ terraform apply     → AWS EC2 (Ubuntu + Docker)
                                                              │
                                    SSH → docker pull from GHCR → run container (port 80)
```

## Tools Used

| Tool | Purpose |
|---|---|
| Git / GitHub | Version control & repository hosting |
| Terraform | Infrastructure as Code (VPC, Subnets, Security Group, EC2) |
| Docker | Containerizing the frontend (Apache httpd:2.4) |
| Jenkins | CI/CD Automation (build, push image, provision infrastructure) |
| GHCR | Docker Image Registry (`ghcr.io/itsshakirahamed-debug/devops-automation-project`) |
| AWS EC2 | Production Cloud Server (`t3.micro` Ubuntu) |

## Project Structure

```
devops-automation-project/
├── provider.tf    # AWS provider configuration
├── variables.tf   # Configurable variables (region, key_name, instance_type)
├── vpc.tf         # VPC, Subnets, Internet Gateway & Security Group
├── ec2.tf         # Dynamic Ubuntu AMI EC2 Instance & Cloud-Init Docker bootstrap
├── Dockerfile     # httpd image serving index.html
├── index.html     # Interactive Neon Physics Matrix & DevOps HUD
└── .gitignore     # Excludes Terraform state & SSH key files
```

## How It Works

### 1. Terraform Infrastructure
- `provider.tf` configures the AWS provider (`hashicorp/aws ~> 6.0`).
- `variables.tf` defines AWS region (`ap-south-1`), key pair name (`webserver-key`), and instance size (`t3.micro`).
- `vpc.tf` provisions a dedicated VPC (`11.0.0.0/16`), public subnets, internet gateway, route table, and security group.
- `ec2.tf` dynamically fetches the latest official Ubuntu 22.04 LTS AMI and provisions the server.
- **Cloud-Init (User Data)** installs Docker on first boot and starts a test Apache container on port `8080`.
- Outputs `public_ip` upon deployment completion.

### 2. Docker Application
The `Dockerfile` packages an interactive HTML5/JS physics simulation matrix overlaid with a glassmorphism DevOps pipeline status card into `httpd:2.4`.

### 3. Jenkins Pipeline (Freestyle Project)
- **SCM**: Repository `https://github.com/itsshakirahamed-debug/devops-automation-project.git`, branch `*/main`.
- **Triggers**: Poll SCM (every 5 mins).
- **Environment Credentials**:
  - `GH_USER`: `itsshakirahamed-debug`
  - `GH_TOKEN`: GitHub Personal Access Token (`write:packages`, `read:packages`)
  - `AWS_ACCESS_KEY_ID`: AWS IAM Access Key ID
  - `AWS_SECRET_ACCESS_KEY`: AWS IAM Secret Access Key

#### Windows Batch Build Commands:
```bat
:: Build and push Docker image to GHCR
docker build -t ghcr.io/%GH_USER%/devops-automation-project:latest .
echo %GH_TOKEN%| docker login ghcr.io -u %GH_USER% --password-stdin
docker push ghcr.io/%GH_USER%/devops-automation-project:latest

:: Initialize and apply Terraform infrastructure
terraform init -input=false
terraform apply -auto-approve -input=false
terraform output -raw public_ip
```

---

## Step-by-Step Setup Guide

### 1. Create AWS Credentials & Key Pair
1. Log in to AWS Management Console.
2. Go to **EC2** → **Key Pairs** → **Create key pair**:
   - Name: `webserver-key`
   - File format: `.pem`
   - Download and keep `webserver-key.pem` safe.
3. Go to **IAM** → **Users** → Generate **Access Key ID** & **Secret Access Key**.

### 2. Generate GitHub Personal Access Token (PAT)
1. Go to GitHub → **Settings** → **Developer Settings** → **Personal Access Tokens (classic)**.
2. Click **Generate new token**.
3. Enable scopes: `write:packages`, `read:packages`, `delete:packages`.
4. Copy the token string.

### 3. Add Jenkins Credentials
In Jenkins → **Manage Jenkins** → **Credentials** → **Global credentials**:
- `GH_USER` (Secret text): `itsshakirahamed-debug`
- `GH_TOKEN` (Secret text): Your GitHub PAT
- `AWS_ACCESS_KEY_ID` (Secret text): Your AWS Access Key ID
- `AWS_SECRET_ACCESS_KEY` (Secret text): Your AWS Secret Access Key

### 4. Deploy Infrastructure & Container
1. Trigger **Build Now** in Jenkins.
2. Copy the EC2 Public IP from Jenkins Console Output.
3. SSH into the EC2 instance:
   ```bash
   ssh -i webserver-key.pem ubuntu@<EC2_PUBLIC_IP>
   ```
4. Authenticate GHCR and run production container:
   ```bash
   echo <GH_TOKEN> | docker login ghcr.io -u itsshakirahamed-debug --password-stdin
   docker pull ghcr.io/itsshakirahamed-debug/devops-automation-project:latest
   docker run -d --name web --restart always -p 80:80 ghcr.io/itsshakirahamed-debug/devops-automation-project:latest
   ```
5. Open `http://<EC2_PUBLIC_IP>` in your browser.

---

## Verifying Deployment

| URL | Component |
|---|---|
| `http://<EC2_PUBLIC_IP>:8080` | Default Apache test container (bootstrap check) |
| `http://<EC2_PUBLIC_IP>` | **Production Interactive DevOps App** |

---

## Cleanup

To avoid unexpected AWS charges, destroy resources when finished:
```bash
terraform destroy -auto-approve
```
