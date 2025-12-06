#!/usr/bin/env bash
# Usage: ./bootstrap.sh <PROJECT_ID> <BILLING_ACCOUNT_ID>
# Example: ./bootstrap.sh james-demo-123 012345-ABCDEF-789012
set -euo pipefail

PROJECT_ID="${1:-}"
BILLING_ACCOUNT="${2:-}"

# -------- helpers --------
err() { echo "ERROR: $*" >&2; }
info() { echo "INFO: $*"; }

# -------- validate inputs --------
if [[ -z "${PROJECT_ID}" || -z "${BILLING_ACCOUNT}" ]]; then
  err "PROJECT_ID and BILLING_ACCOUNT are required."
  exit 1
fi

# -------- check auth context --------
# Cloud Build SA must have resourcemanager.projectCreator and billing.user.
gcloud auth list || true

# -------- check if project already exists --------
if gcloud projects describe "${PROJECT_ID}" >/dev/null 2>&1; then
  info "Project ${PROJECT_ID} already exists. Skipping creation."
else
  info "Creating project: ${PROJECT_ID}"
  gcloud projects create "${PROJECT_ID}"
fi

# -------- set default project --------
gcloud config set project "${PROJECT_ID}"

# -------- verify billing account visibility --------
if ! gcloud beta billing accounts list --filter="name:${BILLING_ACCOUNT}" --format="value(name)" | grep -qx "${BILLING_ACCOUNT}"; then
  err "Billing account ${BILLING_ACCOUNT} not found or not visible to current identity."
  err "Ensure Cloud Build SA has roles/billing.user and the billing account is in same org."
  exit 1
fi

# -------- link billing (idempotent) --------
if gcloud beta billing projects describe "${PROJECT_ID}" --format="value(billingAccountName)" | grep -q "${BILLING_ACCOUNT}"; then
  info "Project ${PROJECT_ID} already linked to billing ${BILLING_ACCOUNT}."
else
  info "Linking billing account ${BILLING_ACCOUNT} to project ${PROJECT_ID}."
  gcloud beta billing projects link "${PROJECT_ID}" --billing-account="${BILLING_ACCOUNT}"
fi

# -------- enable minimal baseline APIs --------
info "Enabling baseline APIs (iam, serviceusage)."
gcloud services enable iam.googleapis.com serviceusage.googleapis.com

info "Bootstrap complete for ${PROJECT_ID}."
