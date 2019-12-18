#!/bin/bash -u

readonly GCS_MODEL_DIR="gs://caip_notebooks_demo_temp/models/saved_model/"
readonly PROJECT_ID="caip-notebooks-demo"
readonly MODEL_NAME="test_model"
readonly COMMIT="${1}"
readonly COMMIT_SUB_STRING_FOR_VERSION=$(echo ${COMMIT} | cut -c1-5)
# Date is required for the cases when same commit deployment happesn twice
readonly VERSION_NAME="commit_${COMMIT_SUB_STRING_FOR_VERSION}_$(date +%m_%d_%Y_%M%S)"
readonly FRAMEWORK="tensorflow"

# One time operaion for creating new model
# gcloud ai-platform models create "${MODEL_NAME}" --project "${PROJECT_ID}"

echo "starting command with VERSION_NAME: ${VERSION_NAME}"
echo "starting command with MODEL_NAME: ${MODEL_NAME}"
echo "starting command with GCS_MODEL_DIR: ${GCS_MODEL_DIR}"
echo "starting command with GCS_MODEL_DIR: ${FRAMEWORK}"
echo "starting command with GCS_MODEL_DIR: ${PROJECT_ID}"

gcloud ai-platform versions create "${VERSION_NAME}" \
  --model "${MODEL_NAME}" \
  --origin "${GCS_MODEL_DIR}" \
  --runtime-version=1.14 \
  --framework "${FRAMEWORK}" \
  --python-version=3.5 \
  --project "${PROJECT_ID}"

# Cleaning
# gsutil rm -rf "${GCS_MODEL_DIR}"
