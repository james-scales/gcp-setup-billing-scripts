#!/usr/bin/env python3
"""
Minimal cost monitor that queries a BigQuery billing export table.
Set environment variables:
  BILLING_PROJECT  - project that contains the billing export dataset
  BILLING_DATASET  - dataset name
  BILLING_TABLE    - table name (usually billing_export_v1 or similar)
Requires: pip install google-cloud-bigquery
"""

import os
from google.cloud import bigquery
from datetime import datetime, timedelta

BILLING_PROJECT = os.environ.get("BILLING_PROJECT", "")
BILLING_DATASET = os.environ.get("BILLING_DATASET", "")
BILLING_TABLE = os.environ.get("BILLING_TABLE", "")

if not (BILLING_PROJECT and BILLING_DATASET and BILLING_TABLE):
    raise SystemExit("BILLING_PROJECT BILLING_DATASET BILLING_TABLE must be set")

client = bigquery.Client(project=BILLING_PROJECT)

# Query last 7 days cost summary
query = f"""
SELECT
  DATE(usage_start_time) AS day,
  SUM(cost) AS total_cost
FROM `{BILLING_PROJECT}.{BILLING_DATASET}.{BILLING_TABLE}`
WHERE usage_start_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY day
ORDER BY day DESC
LIMIT 7
"""

job = client.query(query)
rows = job.result()

print("Last 7 days cost summary")
for row in rows:
    print(f"{row.day}: ${row.total_cost:.2f}")
