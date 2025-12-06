from google.cloud import bigquery
import smtplib

client = bigquery.Client()

query = """
SELECT service.description, SUM(cost) as total_cost
FROM `my_project.billing_dataset.gcp_billing_export`
WHERE usage_start_time >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY service.description
ORDER BY total_cost DESC
LIMIT 5
"""

results = client.query(query).result()

total = sum(row.total_cost for row in results)

if total > 100:  # threshold
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login("me@example.com", "password")
        server.sendmail("me@example.com", "team@example.com",
                        f"Subject: GCP Cost Alert\n\nYesterday's spend was ${total:.2f}")
