#!/bin/bash -u

NOTEBOOK_GCS_PATH="gs://notebooks-ci/demo.ipynb"
NOTEBOOK_OUT_GCS_PATH="gs://notebooks-ci/demo-out.ipynb"

gsutil cp ./demo.ipynb "${NOTEBOOK_GCS_PATH}"

UUID=$(cat /proc/sys/kernel/random/uuid)
JOB_NAME=$(echo "demo-nb-run-${UUID}" | tr '-' '_')
REGION="us-central1"
IMAGE_NAME=$(<container_uri)
gcloud beta ai-platform jobs submit training "${JOB_NAME}" \
  --region "${REGION}" \
  --master-image-uri "${IMAGE_NAME}" \
  --stream-logs \
  -- nbexecutor \
  --input-notebook "${NOTEBOOK_GCS_PATH}" \
  --output-notebook "${NOTEBOOK_OUT_GCS_PATH}"