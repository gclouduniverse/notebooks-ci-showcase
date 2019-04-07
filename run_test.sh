#!/bin/bash -u

source gcp-notebook-executor/utils.sh

INPUT_NOTEBOOK="demo.ipynb"
GCS_LOCATION="gs://dl-platform-temp/notebook-ci-showcase"

# This is in order to remove new line at the end of the string.
API_KEY=`echo "${API_KEY}"`

execute_notebook -i "./${INPUT_NOTEBOOK}" -o "${GCS_LOCATION}" -m "api_key=${API_KEY}" -g t4 -c 1
