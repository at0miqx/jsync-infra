# GitHub Secrets Setup Guide

After running `terraform apply`, you must manually add the following secrets to both GitHub repositories. Terraform cannot push secrets to GitHub directly.

---

## Step 1: Create the Service Principal

Run these commands once with the Azure CLI:

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create the SP with Contributor role on your subscription
az ad sp create-for-rbac \
  --name "sp-jsync-github-actions" \
  --role "Contributor" \
  --scopes "/subscriptions/${SUBSCRIPTION_ID}" \
  --sdk-auth
```

The output JSON gives you `clientId`, `clientSecret`, `tenantId`, and `subscriptionId`. **Save this — you cannot retrieve the `clientSecret` again.**

---

## Step 2: Add Secrets to `Moonlight304/jsync-infra` (Infrastructure repo)

**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Value |
|---|---|
| `AZURE_CLIENT_ID` | `clientId` from SP JSON |
| `AZURE_CLIENT_SECRET` | `clientSecret` from SP JSON |
| `AZURE_TENANT_ID` | `tenantId` from SP JSON (or `az account show --query tenantId -o tsv`) |
| `AZURE_SUBSCRIPTION_ID` | `subscriptionId` from SP JSON |
| `TF_STATE_RESOURCE_GROUP` | `rg-jsync-tfstate` |
| `TF_STATE_STORAGE_ACCOUNT` | Printed by `bootstrap.ps1` / `bootstrap.sh` |
| `TF_STATE_CONTAINER` | `tfstate` |
| `JWT_SECRET` | A long random string (e.g. `openssl rand -base64 48`) |
| `GROQ_API_KEY` | Your GROQ API key |
| `SMTP_PASSWORD` | Gmail app password (not your account password) |
| `SMTP_USER` | Your Gmail address (e.g. `myapp@gmail.com`) |
| `APP_ADMIN_PASSWORD` | Initial admin account password for the app |

---

## Step 3: Add Secrets to `Harsith/JRMS` (Application repo)

| Secret Name | Value |
|---|---|
| `AZURE_CLIENT_ID` | Same SP `clientId` |
| `AZURE_CLIENT_SECRET` | Same SP `clientSecret` |
| `AZURE_TENANT_ID` | Same |
| `AZURE_SUBSCRIPTION_ID` | Same |
| `ACR_LOGIN_SERVER` | `terraform output -raw acr_login_server` |
| `AZURE_RESOURCE_GROUP` | `terraform output -raw resource_group_name` |
| `NEXT_PUBLIC_APP_NAME` | `"Resource Manager Engine"` (or whatever you want) |

---

## Step 4: Fix the client Dockerfile for `NEXT_PUBLIC_APP_NAME`

`NEXT_PUBLIC_*` variables in Next.js are **baked into the bundle at build time** — they cannot be injected at runtime. Make sure your `client/Dockerfile` includes:

```dockerfile
# Declare the build arg
ARG NEXT_PUBLIC_APP_NAME
# Expose it as an env var so Next.js picks it up during `next build`
ENV NEXT_PUBLIC_APP_NAME=$NEXT_PUBLIC_APP_NAME
```

This must appear **before** the `RUN npm run build` (or `RUN next build`) step.

---

## Step 5: Configure Gmail SMTP

The server uses Gmail SMTP. You need to use an **App Password**, not your regular Gmail password:

1. Go to [myaccount.google.com](https://myaccount.google.com)
2. Search for **App passwords**
3. Create one for "Mail" / "Other" → name it `jsync`
4. Use that 16-character password as `SMTP_PASSWORD`
5. Use your Gmail address as `SMTP_USER`

---

## Step 6: Verify after first apply

```bash
# Get the client public URL
terraform output client_url

# Get ACR login server (for Harsith/JRMS GitHub Secrets)
terraform output -raw acr_login_server

# Get the resource group name (for Harsith/JRMS GitHub Secrets)
terraform output -raw resource_group_name
```

---

## Environment Variable Map

Here's how every variable from your `.env.example` files is handled:

### Server (`server/.env.example`)

| Variable | How it's set |
|---|---|
| `DB_USER` | Terraform → Container App env var (`var.db_admin_username`) |
| `DB_PASSWORD` | Terraform auto-generates → Container App secret |
| `DB_HOST` | Terraform → Container App env var (MySQL FQDN) |
| `DB_PORT` | Hardcoded `3306` in Container App |
| `DB_NAME` | Terraform → Container App env var |
| `MYSQL_DATABASE` | Not needed — only used by Docker Compose |
| `JWT_SECRET` | GitHub Secret → `-var` → Key Vault → Container App secret |
| `GROQ_API_KEY` | GitHub Secret → `-var` → Key Vault → Container App secret |
| `PORT` | Hardcoded `8080` in Container App |
| `MTP_HOST` | `terraform.tfvars` → `smtp_host` → Container App env var |
| `SMTP_PORT` | `terraform.tfvars` → `smtp_port` → Container App env var |
| `SMTP_USER` | GitHub Secret → `-var` → Container App env var |
| `SMTP_PASSWORD` | GitHub Secret → `-var` → Key Vault → Container App secret |
| `SMTP_FROM` | `terraform.tfvars` → `smtp_from` → Container App env var |
| `ADMIN_USERNAME` | `terraform.tfvars` → `admin_username` → Container App env var |
| `ADMIN_PASSWORD` | GitHub Secret → `-var` → Key Vault → Container App secret |

### Client (`client/.env.example`)

| Variable | How it's set |
|---|---|
| `NEXT_PUBLIC_APP_NAME` | GitHub Secret → `--build-arg` in Docker build → baked into bundle |
| `BACKEND_URL` | Hardcoded `http://jsync-server` in Container App (internal DNS) |
| `PORT` | Hardcoded `3000` in Container App |
