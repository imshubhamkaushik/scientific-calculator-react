#!/usr/bin/env bash

# Synthetic check script for Scientific Calculator frontend
# Assumes IAM instance role with CloudWatch permissions

# This relies on:
# - IAM role we attached in Terraform (cloudwatch:PutMetricData).
# - awscli installed (done in user_data and common).

LOUDFRONT_URL="$1"
NAMESPACE="ScientificCalculator"
METRIC_AVAILABLILITY="SyntheticAvailablity"
METRIC_LATENCY="SyntheticLatencyMs"
LOG_FILE="/var/log/synthetic_check.log"

if [[ -z "$LOUDFRONT_URL" ]]; then
  echo "$(date -Iseconds) - ERROR: CLOUDFRONT_URL is required" | tee -a "$LOG_FILE"
  exit 1
fi

START_TIME=$(date +%s%3N)

HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$LOUDFRONT_URL")
CURL_EXIT=$?

END_TIME=$(date +%s%3N)
LATENCY_MS=$((END_TIME - START_TIME))

AVAILABILITY=0

if [[ $CURL_EXIT -eq 0 && $HTTP_CODE -eq 200 && "$HTTP_CODE" -lt 400]]; then
  AVAILABILITY=1
fi

echo "$(date -Iseconds) - URL=$CLOUDFRONT_URL CODE=$HTTP_CODE LATENCY=${LATENCY_MS}ms AVAILABILITY=$AVAILABILITY" >> "$LOG_FILE"

# Publish custom metrics to CloudWatch
aws cloudwatch put-metric-data \
  --namespace "$NAMESPACE" \
  --metric-data "[
    {
      \"MetricName\": \"{$METRIC_AVAILABILITY}\",
      \"Unit\": \"None\",
      \"Value\": ${AVAILABILITY}
    },
    {
      \"MetricName\": \"{$METRIC_LATENCY}\",
      \"Unit\": \"Milliseconds\",
      \"Value\": ${LATENCY_MS}
    }
  ]"