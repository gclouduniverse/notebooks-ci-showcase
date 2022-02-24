#!/bin/bash

ENDPOINT_ID="8163478012050800640"
PROJECT_ID="183488370666"

curl \
-X POST \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
https://us-west1-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-west1/endpoints/${ENDPOINT_ID}:predict \
-d "@request.json"