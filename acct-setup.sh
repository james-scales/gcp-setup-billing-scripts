#!/bin/bash
# Usage: ./bootstrap.sh <PROJECT_ID> <BILLING_ACCOUNT>
# Example: ./bootstrap.sh my-new-project 012345-ABCDEF-789012

PROJECT_ID=$1
BILLING_ACCOUNT=$2

echo "Creating project: $PROJECT_ID"

# Create project
gcloud projects create $PROJECT_ID --set-as-default

# Link billing account
gcloud beta billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT

# Enable core APIs
gcloud services enable compute.googleapis.com \
    iam.googleapis.com \
    container.googleapis.com \
    bigquery.googleapis.com \
    pubsub.googleapis.com

# Create VPC network
gcloud compute networks create default-vpc --subnet-mode=auto

# Create Cloud Storage bucket for logs/backups
gsutil mb -p $PROJECT_ID gs://$PROJECT_ID-logs/

echo "Project $PROJECT_ID setup complete!"