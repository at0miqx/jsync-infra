# jsync-infra

Terraform infrastructure for the [jsync](https://github.com/Harsith/JRMS) application, deployed on Azure.

## Architecture

```
Internet
   │
   ▼
[Azure Container Apps — jsync-client]  (public, port 3000)
   │  internal HTTP
   ▼
[Azure Container Apps — jsync-server]  (internal only, port 8080)
   │  private VNet
   ▼
[Azure Database for MySQL Flexible Server]  (private, no public endpoint)
```

All resources live in a single VNet. Images are pulled from ACR using Managed Identity (no credential rotation needed at runtime). Secrets are stored in Azure Key Vault.

## Repository Structure

```
jsync-infra/
├── bootstrap/          # One-time state backend setup scripts
├── modules/
│   ├── networking/     # VNet, subnets, private DNS
│   ├── acr/            # Azure Container Registry
│   ├── keyvault/       # Key Vault + secrets
│   ├── mysql/          # MySQL Flexible Server
│   └── container_apps/ # Container App Environment + apps
├── app-workflows/      # Copy these to Harsith/JRMS/.github/workflows/
├── .github/workflows/  # Infra CI/CD (terraform plan/apply)
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf
└── terraform.tfvars
```

## Prerequisites

- Azure CLI (`az`) installed and logged in
- Terraform >= 1.5.0
- Sufficient Azure subscription permissions (Contributor)

## First-Time Setup

### 1. Bootstrap the Terraform state backend

**Windows (PowerShell):**
```powershell
.\bootstrap\bootstrap.ps1
```

**Linux/Mac:**
```bash
bash bootstrap/bootstrap.sh
```

The script creates a dedicated resource group (`rg-jsync-tfstate`) and storage account for Terraform state. **Update `backend.tf`** with the generated storage account name, then commit.

### 2. Create the Service Principal for GitHub Actions

See [github-secrets-instructions.md](./github-secrets-instructions.md) for the full SP creation command and all required GitHub Secrets for both repos.

### 3. Initialize Terraform

```bash
terraform init \
  -backend-config="resource_group_name=rg-jsync-tfstate" \
  -backend-config="storage_account_name=<your-storage-account>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=jsync.terraform.tfstate"
```

### 4. Plan and Apply

```bash
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### 5. Set up App Repo Workflows

Copy `app-workflows/server.yml` and `app-workflows/client.yml` into `Harsith/JRMS/.github/workflows/`. Add the required GitHub Secrets listed in [github-secrets-instructions.md](./github-secrets-instructions.md).

### 6. Push your first image

After Terraform provisions the infrastructure, trigger the app repo workflows by pushing a change to `server/` or `client/`. The Container Apps will update to use your real images.

## Changing the Region

Edit `terraform.tfvars`:
```hcl
location = "eastus"  # or any region allowed by your subscription
```

Then run `terraform apply`.

## Useful Commands

```bash
# See all outputs (URLs, ACR server, etc.)
terraform output

# Get the live client URL
terraform output -raw client_url

# Destroy all app resources (state backend is safe)
terraform destroy -var-file="terraform.tfvars"
```

## CI/CD Pipelines

| Repo | Workflow | Trigger | Action |
|---|---|---|---|
| `Moonlight304/jsync-infra` | `terraform.yml` | PR to `main` | fmt check, validate, plan (posted as comment) |
| `Moonlight304/jsync-infra` | `terraform.yml` | Merge to `main` | terraform apply |
| `Harsith/JRMS` | `server.yml` | Changes in `server/` on `main` | Build + push server image → update Container App |
| `Harsith/JRMS` | `client.yml` | Changes in `client/` on `main` | Build + push client image → update Container App |
