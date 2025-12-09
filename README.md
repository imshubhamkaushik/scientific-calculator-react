# Scientific Calculator – AWS DevOps Project (Terraform · Ansible · Jenkins · AWS)

A production-style DevOps project built around a **React-based Scientific Calculator** frontend app.

The goal of this project is to showcase **1–2 years equivalent DevOps experience** using a **static frontend** and a realistic, AWS-native infrastructure:

- Static hosting on **S3 + CloudFront**
- **VPC + EC2** for monitoring / bastion
- **Terraform** for modular, environment-based IaC
- **Ansible** for EC2 configuration & hardening
- **Bash scripts** for end-to-end automation
- **Jenkins** for CI/CD
- **CloudWatch + SNS** for monitoring & alerts
- **No Kubernetes / Prometheus / Grafana** – only AWS-native monitoring

---

## 1. High-Level Architecture

- **React Scientific Calculator** built as a static SPA.
- Deployed to an **S3 bucket** and served globally via **CloudFront**.
- A dedicated **EC2 monitoring/bastion instance** inside a **VPC**:
  - Configured and hardened via **Ansible**.
  - Runs a **synthetic monitoring Bash script** hitting the CloudFront URL.
  - Publishes **custom metrics** to **CloudWatch**.
- **CloudWatch** collects:
  - Native metrics (EC2, CloudFront)
  - Custom metrics (Synthetic Availability & Latency)
  - Logs via CloudWatch Agent.
- **CloudWatch Alarms** send notifications via **SNS email**.
- **Jenkins Pipeline** runs:
  - Terraform plan/apply
  - Ansible configuration
  - Frontend build & deployment to S3 + CloudFront.

### 1.1 Architecture Diagram (Mermaid)

```mermaid
flowchart LR
    Dev[Developer / Jenkins] -->|git push / webhook| Jenkins[Jenkins Pipeline]

    subgraph AWS
        subgraph VPC
            EC2[EC2 Monitor/Bastion\nAmazon Linux 2]
        end

        S3[(S3 Frontend Bucket)]
        CF[CloudFront Distribution]
        SNS[(SNS Alerts)]
        CW[CloudWatch\nMetrics + Logs + Alarms]
    end

    Jenkins -->|Terraform\n(provision_infra.sh)| VPC
    Jenkins -->|Terraform\nS3 + CF module| S3
    Jenkins -->|Terraform\nS3 + CF module| CF

    Jenkins -->|Ansible\n(configure_ec2.sh)| EC2
    Jenkins -->|Build + Deploy\n(build_frontend.sh + deploy_frontend.sh)| S3

    EC2 -->|Synthetic check script\ncurl CloudFront URL| CF
    EC2 -->|Custom metrics\nPutMetricData| CW
    EC2 -->|CW Agent logs & system metrics| CW

    CW -->|Alarms| SNS --> Dev
```

2. Tech Stack

- Cloud / Infra

  AWS: S3, CloudFront, VPC, EC2, IAM, CloudWatch, SNS
  Terraform: modular, environment-based (infra/terraform)
  Ansible: roles and playbooks for EC2 configuration (ansible/)

- Automation & CI/CD

  Jenkins (declarative pipeline via Jenkinsfile)
  Bash scripts (scripts/) for:
  Infrastructure provisioning
  EC2 configuration
  React build & deploy
  Terraform output export

- Frontend

  React SPA (Scientific Calculator)
  Built with npm run build, static assets in /build

3. Repository Structure

```
scientific-calculator-react/
├── ansible/
│ ├── roles/
│ │ ├── common/ # OS updates, base tools, time sync
│ │ ├── hardening/ # SSH hardening (no password, no root login)
│ │ ├── cloudwatch_agent/ # CloudWatch agent config & restart
│ │ └── synthetic_checks/ # Synthetic monitor script + cron
│ └── playbooks/
│ └── site.yml # Main playbook for EC2 monitor
│
├── infra/
│ └── terraform/
│ ├── modules/
│ │ ├── network/ # VPC, subnet, IGW, route table
│ │ ├── s3_cloudfront/ # S3 bucket, OAC, CloudFront distribution
│ │ ├── ec2_monitor/ # EC2 instance, SG, IAM role/profile
│ │ └── cloudwatch/ # SNS topic & alarms (EC2 + synthetic metrics)
│ └── envs/
│ └── dev/ # Root module for dev environment
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ ├── provider.tf
│ ├── backend.tf # Optional remote backend (S3+DynamoDB)
│ └── terraform.tfvars
│
├── scripts/
│ ├── provision_infra.sh # Terraform init/plan/apply wrapper
│ ├── configure_ec2.sh # Fetch EC2 DNS from TF outputs & run Ansible
│ ├── build_frontend.sh # npm ci/test/build → ./build
│ ├── deploy_frontend.sh # Sync ./build → S3 + CloudFront invalidation
│ └── export_tf_outputs.sh # Export TF outputs to JSON for debugging/CI
│
├── Jenkinsfile # Jenkins CI/CD pipeline
├── src/ # React source code
├── public/ # Static assets (CRA-style)
├── build/ # Production build output (gitignored)
├── package.json
└── README.md
```

4. Infrastructure as Code (Terraform)
   4.1 Modules

- network

  Creates VPC, public subnet, Internet Gateway, route table.

  Used to place the EC2 monitoring instance in a controlled network.

- s3_cloudfront

  Creates:

        Private S3 bucket (block public access) for static frontend hosting.

        CloudFront Origin Access Control (OAC).

        CloudFront distribution with SPA-friendly error handling (403/404 → index.html).

        Optional S3 logs bucket for CloudFront access logs.

  Exposes:

        bucket_name
        cloudfront_distribution_id
        cloudfront_domain_name

- ec2_monitor

  Creates:

        Security group (SSH from a configured CIDR only, full outbound).

        IAM role + instance profile with:

            AmazonSSMManagedInstanceCore
            Custom policy for CloudWatch logs & metrics.

        EC2 instance (Amazon Linux 2) in the public subnet.

        User data for base tooling (Python, CloudWatch Agent, etc.).

  Exposes:

        instance_id
        public_ip
        public_dns

- cloudwatch

      Creates:

          SNS topic for alerts.
          Email subscription to a configured email.
          CloudWatch alarms for:
              EC2 StatusCheckFailed
              Custom metric ScientificCalculator/SyntheticAvailability (from synthetic script).

  4.2 Environment-based Root Module (infra/terraform/envs/dev)

- Wires modules together:

  module "network" { ... }
  module "s3_cloudfront" { ... }
  module "ec2_monitor" { vpc_id = module.network.vpc_id ... }
  module "cloudwatch" { monitor_instance_id = module.ec2_monitor.instance_id ... }

- Uses variables.tf + terraform.tfvars to define:

  CIDR blocks
  Region
  Project + environment names
  SSH key name for EC2
  SNS alert email

- Optionally uses backend.tf for remote state:

      S3 bucket + DynamoDB lock table

      In a real setup, these are either created once manually or via a separate “backend bootstrap” Terraform project.

  4.3 Terraform Wrapper Script

./scripts/provision_infra.sh:

    ./scripts/provision_infra.sh dev plan
        Runs terraform init and terraform plan in envs/dev.

    ./scripts/provision_infra.sh dev apply
        Runs terraform init and terraform apply -auto-approve.

This is what Jenkins uses in the Terraform Plan / Apply stages.

5. Configuration Management (Ansible)
   5.1 Roles

- common

  Updates all packages.
  Installs base tools: git, curl, jq, htop, etc.
  Sets up time synchronization using chronyd.

- hardening

  Edits /etc/ssh/sshd_config:
  Disables password authentication.
  Disables root login.
  Enforces SSH protocol 2.

  Restarts sshd.

- cloudwatch_agent

  Places amazon-cloudwatch-agent.json config via template.

  Configures:

        Logs: /var/log/messages, /var/log/secure → CloudWatch Logs groups.

        Metrics: CPU and memory usage → CloudWatch Metrics.

  Restarts the agent with the new config.

- synthetic_checks

      Deploys synthetic_check.sh to /usr/local/bin/.

      Prepares a log file /var/log/synthetic_check.log.

      Sets up a cron job (every 5 minutes):

          synthetic_check.sh <CloudFront URL>

          Uses instance IAM role to call aws cloudwatch put-metric-data.

          Sends:

              ScientificCalculator/SyntheticAvailability (1 = OK, 0 = Fail)
              ScientificCalculator/SyntheticLatencyMs.

  5.2 Playbook
  ansible/playbooks/site.yml:

- Targets the monitor host group (the EC2 instance).
- Applies roles in order:
  common → hardening → cloudwatch_agent → synthetic_checks.
- Accepts the CloudFront URL as a variable synthetic_target_url.

  5.3 Ansible Wrapper Script
  ./scripts/configure_ec2.sh:

- Reads monitor_public_dns from Terraform outputs.

- Generates a temporary inventory file.

- Uses ANSIBLE_SSH_KEY_PATH environment variable for the private key.

- Runs ansible-playbook ansible/playbooks/site.yml.

Usage:

    export ANSIBLE_SSH_KEY_PATH=~/.ssh/your-key.pem
    ./scripts/configure_ec2.sh dev

6. Frontend Build & Deployment

6.1 Build Script
./scripts/build_frontend.sh:

- Runs from repo root.

- Installs dependencies:

  npm ci if package-lock.json exists.
  npm install otherwise.

- Runs tests if a test script exists in package.json.

- Builds the app:
  NODE_ENV=production npm run build

- Verifies the ./build directory exists.

  6.2 Deploy Script

./scripts/deploy_frontend.sh:

- Reads:

  frontend_bucket_name
  cloudfront_distribution_id
  cloudfront_domain_name from Terraform outputs (envs/dev).

- Syncs the ./build directory to the S3 bucket:
  aws s3 sync build/ s3://<bucket>/ --delete

- Creates a CloudFront invalidation for /\* so updated assets are served.

Usage:

    ./scripts/build_frontend.sh
    ./scripts/deploy_frontend.sh dev

7. CI/CD with Jenkins
   The Jenkinsfile defines a declarative pipeline:

Stages:-

- Checkout

Pulls the latest code from Git.

- Terraform Plan (dev)

Runs ./scripts/provision_infra.sh dev plan with AWS credentials from Jenkins (aws-dev-creds).

- Terraform Apply (dev) (conditional)

Only runs if APPLY_INFRA=true is set as a build parameter.

Runs ./scripts/provision_infra.sh dev apply.

- Configure Monitor EC2 (Ansible) (conditional)

Controlled by CONFIGURE_EC2=true build parameter.

Uses:
AWS credentials (aws-dev-creds) to read Terraform outputs.
SSH key credentials (ansible-ssh-key) for Ansible.

Runs ./scripts/configure_ec2.sh dev.

- Build Frontend
  Runs ./scripts/build_frontend.sh.

- Deploy Frontend to S3 + CloudFront
  Runs ./scripts/deploy_frontend.sh dev with AWS credentials.

Post Actions

In post { always { ... } }:

    Runs ./scripts/export_tf_outputs.sh dev (with AWS creds) to dump all Terraform outputs to JSON.

Archives:

    infra/terraform/envs/dev/terraform-outputs-dev.json
    so each Jenkins build has a record of the current infra state.

Jenkins Credentials Used
aws-dev-creds → AWS access keys with necessary permissions.

    ansible-ssh-key → SSH private key matching monitor_key_name used in Terraform (EC2 key pair).

8. Monitoring & Alerts

CloudWatch Agent on the EC2 monitor:

System metrics: CPU, memory.
Logs: /var/log/messages, /var/log/secure.

Synthetic Monitoring Script from EC2:

Periodically hits the CloudFront URL.
Publishes:

ScientificCalculator/SyntheticAvailability
ScientificCalculator/SyntheticLatencyMs

CloudWatch Alarms:

EC2 StatusCheckFailed > 0 for 2 periods.
Synthetic availability average < 0.99 across 2× 5-minute periods.

SNS:

Topic for alerts.
Email subscription for notifications.

9. How to Run End-to-End (Dev Environment)

Prerequisites

AWS account & IAM user/role with permissions for:
EC2, VPC, S3, CloudFront, IAM, CloudWatch, SNS.

Tools installed locally or on Jenkins agent:
terraform, aws, ansible, node, npm, bash.

EC2 key pair created in AWS (for SSH) and name referenced in terraform.tfvars.

Steps (Manual)

# 1) Provision or update infrastructure

./scripts/provision_infra.sh dev apply

# 2) Configure monitoring EC2 (Ansible)

export ANSIBLE_SSH_KEY_PATH=~/.ssh/your-key.pem
./scripts/configure_ec2.sh dev

# 3) Build frontend

./scripts/build_frontend.sh

# 4) Deploy frontend

./scripts/deploy_frontend.sh dev

# 5) (Optional) Export Terraform outputs to JSON

./scripts/export_tf_outputs.sh dev
After deployment, the app is available at:

https://<cloudfront_domain_name>/
(from Terraform output / deploy script logs).

10. Cost & Cleanup

This project uses:

1 t3.micro (or similar) EC2 instance
S3 storage + CloudFront data transfer (low for small project)
CloudWatch + SNS (minimal cost)

To minimize cost:

Use only dev environment.
Stop or terminate the EC2 instance when not in use.

To fully clean up dev infra:

cd infra/terraform/envs/dev
terraform destroy

```

```
