# ☁️ Cloud Computing Project  
## Multi-Tenant Kubernetes Platform with Terraform

**Student:** Nelson Zarate  
**Project:** Infrastructure as Code (IaC) – Odoo Deployment  
**Tech Stack:** Terraform · Kubernetes · Minikube · Docker · GNU Make

---

## 📘 Project Overview

This project implements a **Cloud Platform Engineering solution** capable of dynamically provisioning **isolated Kubernetes environments for multiple enterprise clients**, such as:

- 🏨 AirBnB  
- 👟 Nike  
- 🍔 McDonalds  

The platform follows a **Single Project, Multi-Tenant** architecture where a single Terraform codebase manages:

- **Infrastructure:** One Minikube cluster per client  
- **Application:** Odoo ERP + PostgreSQL  
- **Environments:** Dev, QA, and Prod  
- **Security:** HTTPS via self-signed TLS certificates and Kubernetes Ingress  

Each client and environment is **fully isolated**, reproducible, and easy to destroy.

---

## 🏗 Architecture & Design Decisions

### 1️⃣ Workspace-Based Isolation

Managing multiple Minikube clusters in a single Terraform state is complex and unstable.  
To solve this, the project uses **Terraform Workspaces**:

- **1 Workspace = 1 Client**
- Example: `nike`, `airbnb`, `mcdonalds`
- Each client has its own isolated state file

✅ This guarantees safe resource creation and destruction without cross-client interference.

---

### 2️⃣ Root vs Module Architecture

The infrastructure is split into **physical** and **logical** layers:

#### 🔹 Root Layer (`/infra`)
Responsible for:
- Minikube cluster provisioning  
- Waiting for cluster readiness  
- Installing the Ingress Controller  
- Calling application modules  

#### 🔹 Module Layer (`/infra/modules/odoo`)
Responsible for:
- Kubernetes Namespaces  
- Odoo Deployment & Service  
- PostgreSQL StatefulSet  
- TLS Secrets  
- Ingress rules  

This separation improves **reusability**, **clarity**, and **maintainability**.

---

### 3️⃣ Dynamic Environment Injection

Environments are **not hard-coded**.  
Terraform uses `locals`, `maps`, and `for_each` to dynamically generate resources.

- **Environments:** Defined in `.tfvars`
- **Namespaces:** `client-environment`  
  - Example: `nike-dev`
- **Domains:** `odoo.<env>.<client>.local`
  - Always lowercase

This allows adding environments or clients with **zero code duplication**.

---

## 📂 Project Structure

```text
.
├── Makefile              # Automation: init, apply, test, clean
├── main.tf               # Cluster provisioning & module calls
├── variables.tf          # Global variables
├── terraform.tf          # Provider versions
├── modules/
│   └── odoo/
│       ├── main.tf       # Namespace & provider logic
│       ├── odoo.tf       # Odoo deployment & service
│       ├── database.tf   # PostgreSQL StatefulSet
│       ├── secrets.tf    # TLS certificate generation
│       └── ingress.tf    # HTTPS ingress rules
├── nike.tfvars           # Client configuration: Nike
├── airbnb.tfvars         # Client configuration: AirBnB
└── mcdonalds.tfvars      # Client configuration: McDonalds
```

## How to Run the Project

All project operations are fully automated using a **Makefile**, ensuring consistent, repeatable, and reliable deployments across all clients and environments.

## deploy the project in one command line
```bash
make deploy-all
```
---

### Prerequisites

Before running the project, ensure the following tools are installed on the system:

- Terraform  
- Minikube (Docker driver)  
- Docker  
- GNU Make  

---

### Environment Initialization

The initialization step prepares the local environment by downloading the required Terraform providers and configuring the project workspace.  
This process must be completed once before deploying any client.

```bash
make init
```
---

### Client Deployment

Each client is deployed independently using **Terraform workspaces**.

During a client deployment, the platform:
- Selects or creates the appropriate workspace  
- Provisions a dedicated Minikube cluster  
- Installs and validates the Ingress Controller  
- Deploys Odoo and PostgreSQL for all configured environments  

This design guarantees full isolation between clients and environments.

```bash
make nike
make airbnb
make mcdonalds
```
---

### Local DNS Configuration

To access the deployed applications locally (for example, `odoo.dev.nike.local`), the project includes an automated DNS configuration process that:
- Detects the Minikube cluster IP  
- Updates the local hosts file automatically  

This mechanism is compatible with DevContainers.

```bash
make update-hosts
```
---

## Validation

### Automated Validation (Recommended)

The project provides an automated validation workflow that verifies application connectivity across all environments by checking HTTP response codes.  
This ensures that services are correctly deployed and exposed through the Ingress layer.

```bash
make curl-test
```

---

### Manual Validation

Endpoints can also be validated manually using standard HTTP requests.  
Because the platform uses self-signed TLS certificates, browsers and tools may require explicit certificate acceptance.
```bash
curl -k -I https://odoo.dev.nike.local
```
---

## Adding Clients or Environments

### Adding a New Environment

New environments can be added by updating the client-specific variable file.  
After applying the changes, Terraform automatically creates the required namespace and deploys the application stack without any code modifications.

---

### Adding a New Client

Onboarding a new client involves:
- Creating a client-specific variable file  
- Defining the target environments  
- Adding a corresponding target to the Makefile  

The platform will then provision a fully isolated Kubernetes cluster for the new client.

---

## Cleanup

Client environments can be destroyed individually to free system resources.  
```bash
make destroy-nike
```
A full cleanup option is also available to remove all clusters, Terraform state files, and lock files, allowing the project to be reset to a clean state.
```bash
make clean
```
