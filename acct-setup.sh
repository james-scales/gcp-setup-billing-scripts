#!/usr/bin/env bash
# Minimal idempotent bootstrap script
# Usage: ./bootstrap.sh PROJECT_ID BILLING_ACCOUNT_ID
set -euo pipefail

PROJECT_ID="${1:?PROJECT_ID required}"
BILLING_ACCOUNT="${2:?BILLING_ACCOUNT required}"

echo "INFO: creating or verifying project ${PROJECT_ID}"
if gcloud projects describe "${PROJECT_ID}" >/dev/null 2>&1; then
  echo "INFO: project exists, skipping create"
else
  gcloud projects create "${PROJECT_ID}" --set-as-default
fi

echo "INFO: linking billing account ${BILLING_ACCOUNT}"
if gcloud beta billing projects describe "${PROJECT_ID}" --format="value(billingAccountName)" 2>/dev/null | grep -q "${BILLING_ACCOUNT}"; then
  echo "INFO: billing already linked"
else
  gcloud beta billing projects link "${PROJECT_ID}" --billing-account="${BILLING_ACCOUNT}"
fi

echo "INFO: enabling minimal APIs"
gcloud services enable compute.googleapis.com iam.googleapis.com serviceusage.googleapis.com --project="${PROJECT_ID}"

echo "DONE: ${PROJECT_ID} ready"
