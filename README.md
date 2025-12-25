# Cloud Infrastructure Automation on AWS using Terraform & Ansible

**(Terraform · Ansible · AWS · Bash Scripting)**

## Project Overview

This project demonstrates how to provision, configure, and deploy a static React web application on AWS using Infrastructure as Code (IaC) and automation tools.

The primary goal of the project is to showcase core DevOps practices, including:

 - Infrastructure provisioning using Terraform
 - Server configuration using Ansible
 - Workflow orchestration using Bash scripting
 - Hosting static applications using Nginx on EC2
 - Basic infrastructure monitoring using AWS CloudWatch

The project is intentionally designed to be simple, explainable, and automation-focused, avoiding unnecessary complexity.

---

## Why This Tooling?

This project intentionally uses a minimal yet production-relevant DevOps stack:

- **Terraform** for declarative, version-controlled infrastructure provisioning
- **Ansible** for idempotent configuration management and application deployment
- **Bash scripting** to orchestrate workflows and reduce manual steps
- **AWS EC2 + Nginx** for a simple, cost-effective static hosting solution
- **AWS CloudWatch** for native monitoring without additional tooling overhead

The focus is on clarity, automation, and real-world DevOps practices rather than tool sprawl.

---

## Tech Stack

- Frontend: React (Static Web Application)
- Cloud Provider: AWS

  - EC2
  - VPC
  - IAM
  - CloudWatch

- Infrastructure as Code: Terraform
- Configuration Management: Ansible
- Automation & Orchestration: Bash Scripting
- Web Server: Nginx
- Operating System: Linux (EC2)

---

## Architecture Overview

Text-based architecture description:

- AWS infrastructure is provisioned using Terraform
- A custom VPC and security groups are created using reusable Terraform modules
- EC2 instances are launched within the VPC
- Security groups allow inbound HTTP traffic to the EC2 instance
- Ansible installs and configures Nginx on the EC2 instance
- The React build is deployed to the Nginx web root
- AWS CloudWatch monitors instance-level metrics and triggers alerts

Architecture diagram will be added in a future update.

## Automation Workflow

The entire infrastructure and deployment lifecycle is automated end-to-end:

1. Bash scripts act as orchestration wrappers to standardize and automate infrastructure provisioning and application deployment workflows
2. Terraform provisions AWS infrastructure (VPC, EC2, IAM, Security Groups)
3. Ansible configures EC2 instances and installs Nginx
4. React build artifacts are deployed to the web server
5. CloudWatch Agent publishes system metrics for monitoring and alerting

This workflow ensures consistent, repeatable, and auditable deployments.

## How to Run the Project

### Prerequisites

- AWS Account
- AWS CLI configured
- Terraform installed
- Ansible installed
- Bash shell
- SSH key pair for EC2 access

### Option 1: Run Using Bash Automation Scripts (Recommended)

```bash
./scripts/deploy.sh
./scripts/health_check.sh http://<EC2_PUBLIC_IP>
```

These scripts orchestrate the complete deployment workflow by:

- Building the React application locally
- Provisioning AWS infrastructure using Terraform
- Configuring the EC2 instance and deploying the application using Ansible
- Performing a post-deployment health check to verify application availability

This approach ensures a consistent, repeatable, and error-free deployment process.

### Option 2: Run tools manually (for Learning or Debugging)

#### Step 1: Provision Infrastructure

```bash
terraform init
terraform apply
```

#### Step 2: Configure Server and Deploy Application

```bash
ansible-playbook -i ansible/inventories/dev/hosts.ini ansible/playbooks/site.yaml
```

#### Step 3: Access Application

Once deployment is complete, the application can be accessed using the public IP of the EC2 instance.

## Repository Structure

scientific-calculator-react/
├── ansible/
│   ├── inventories/
│   │   └── dev/
│   │       └── hosts.ini
│   ├── playbooks/
│   │   └── site.yaml
│   └── roles/
│       ├── nginx/
│       ├── app/
│       └── cloudwatch/
│
├── infra/
│   └── terraform/
│       ├── env/
│       ├── modules/
│       │   ├── vpc/
│       │   ├── ec2/
│       │   ├── security-group/
│       │   └── iam-cloudwatch/
│       ├── backend.tf
│       ├── provider.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/
│   ├── terraform_infra.sh
│   ├── ansible_deploy.sh
│   ├── build.sh
│   ├── deploy.sh
│   └── health_check.sh
│
├── src/
├── public/
├── build/
├── package.json
└── README.md

---

## Infrastructure as Code (Terraform)

Terraform follows an environment-based structure (env/dev) where each environment acts as a root module invoking reusable infrastructure modules.

### Modules

Terraform configurations are structured using reusable modules to promote maintainability and scalability.

Each module is responsible for a specific infrastructure component, such as:

 - VPC and networking (modules/vpc)

   The VPC module provisions networking components required for EC2 deployment.

 - EC2 instances (modules/ec2)

   The EC2 module provisions compute instances used to host the application.
   
 - Security groups (modules/security-group)

   Security groups are defined as reusable Terraform modules to control network access securely.

 - IAM and CloudWatch (modules/iam-cloudwatch)

   An IAM module configures permissions required for EC2 instances to publish metrics to CloudWatch securely.

This modular approach allows easy reuse across environments and simplifies future extensions.

- provider.tf 
  AWS provider configuration defines region and authentication settings.

- backend.tf 
  Terraform backend configuration ensures consistent state management.

- variables.tf/outputs.tf
  Input variables and outputs are used to parameterize infrastructure and expose required values for downstream automation.

### Environment-based Root Module (infra/terraform/env/dev)

The project follows an environment-based structure, where each environment (e.g., dev) has its own root module.

The root module:

 - Calls reusable Terraform modules

 - Defines environment-specific variables

 - Acts as the single entry point for infrastructure provisioning

This approach aligns with real-world DevOps practices and supports future environment expansion.

### Terraform Wrapper Script

- 'scripts/terraform_infra.sh'

  - Initializes Terraform
  - Validates configuration
  - Applies infrastructure changes

This abstraction simplifies Terraform execution and reduces manual errors.

## Configuration Management (Ansible)

Ansible is used to automate server configuration and application deployment after infrastructure provisioning.

Terraform handles infrastructure, while Ansible handles configuration and deployment.

### Inventory

- ansible/inventories/dev/hosts.ini

  - Defines EC2 target hosts for the dev environment
  - Enables environment-level separation

### Playbook

- ansible/playbooks/site.yaml

  - Acts as the entry point for Ansible execution
  - Orchestrates role execution in the correct order

### Roles

- roles/nginx
  
  The nginx role installs and configures Nginx as a web server to host the static React application.

- roles/app

  The app role handles deployment of the React build artifacts to the Nginx web root with proper permissions.

- roles/cloudwatch

  The cloudwatch role installs and configures the CloudWatch Agent to publish instance-level metrics for monitoring and alerting.

This role-based structure ensures modular, reusable, and idempotent configuration.

### Ansible Wrapper Script

- scripts/ansible_deploy.sh

  - Executes Ansible playbooks with required parameters
  - Ensures repeatable configuration runs

## Frontend Build & Deployment

### Build Script

- scripts/build.sh

  - Installs dependencies
  - Generates a production-ready React build

### Deploy Script

- scripts/deploy.sh

  - Deploys build artifacts to the EC2 instance
  - Ensures correct file permissions
  - Reloads Nginx if required

### Health Check Script

- scripts/health_check.sh

  - Performs post-deployment application health checks
  - Verifies application availability using HTTP status validation

## Monitoring and Observability

- CloudWatch Agent is installed via the cloudwatch Ansible role
- AWS CloudWatch is configured to monitor:

  - CPU utilization
  - Instance health metrics

- Basic CloudWatch alarms are configured
- Alerts notify when defined thresholds are breached

The monitoring setup is intentionally kept lightweight to avoid unnecessary complexity.

## Security Considerations

- IAM roles are used for secure AWS access
- Security groups restrict inbound and outbound traffic
- Nginx runs with least-privilege configuration
- Infrastructure access is controlled via SSH key-based authentication

## Current Limitations

- Deployed and tested in a limited AWS environment
- Screenshots and architecture diagram are pending
- Monitoring is limited to basic metrics
- Focus is on DevOps automation rather than frontend features

## Cost & Cleanup

### Cost Considerations

- EC2 instance
- CloudWatch metrics and alarms
- Networking components (VPC)

Resources are kept minimal for learning purposes.

### Cleanup

To avoid unnecessary AWS charges:

```bash
terraform destroy
```

This command removes all provisioned infrastructure.

## DevOps Best Practices Demonstrated

- Infrastructure as Code with modular Terraform design
- Environment-based infrastructure isolation
- Separation of provisioning and configuration responsibilities
- Idempotent server configuration using Ansible roles
- Scripted automation to minimize manual intervention
- Cost-aware cloud resource usage
- Secure access using IAM roles and SSH key authentication