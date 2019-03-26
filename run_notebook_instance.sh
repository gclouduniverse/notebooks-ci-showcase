#!/bin/bash -u
readonly BUILD_TIME=$(date +%s)
readonly DEFAULT_NOTEBOOK_EXECUTOR_INSTANCE_NAME="notebookexecutor-${BUILD_TIME}"

TESTING_MODE="false"
PARAM_FILE=""

while getopts ":tp:" opt; do
  case ${opt} in
    t )
      TESTING_MODE="true"
      ;;
    p )
      PARAM_FILE=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

function output_for_mode() {
    local TESTING_MODE=$1
    local GCS_LOCATION=$2
    if [[ "${TESTING_MODE}" == "true" ]]; then
        return "${GCS_LOCATION}/results/${BUILD_TIME}"
    else
        return "${GCS_LOCATION}/versions/$(date +%Y-%m-%d)"
    fi
}

function wait_till_instance_not_exist() {
    local INSTANCE_NAME=$1
    local ZONE=$2
    if [ "$#" -ne 2 ]; then
        echo "Usage: "
        echo "   ./wait_till_instance_not_exist [INSTANCE_NAME] [ZONE]"
        echo ""
        echo "example:"
        echo "   ./wait_till_instance_not_exist instance1 us-west1-b"
        echo ""
        return 1
    fi
    while true; do
        if gcloud compute instances describe "${INSTANCE_NAME}" --zone="${ZONE}" > /dev/null; then
            echo "Background execution still in progress, going to sleep 10sec..."
            sleep 10
            continue
        fi
        return 0
    done
}

function execute_notebook_with_gpu() {
    if [ "$#" -ne 4 ]; then
        echo "Usage: "
        echo "   ./execute_notebook_with_gpu [INPUT_NOTEBOOK] [GCS_LOCATION] [GPU_TYPE] [GPU_COUNT]"
        echo ""
        echo "example:"
        echo "   ./execute_notebook_with_gpu test.ipynb gs://my-bucket p100 4"
        echo ""
        return 1
    fi 
    echo "Build id: ${BUILD_TIME}"
    local INPUT_NOTEBOOK=$1
    local GCS_LOCATION=$2
    local GPU_TYPE=$3
    local GPU_COUNT=$4
    NOTEBOOK_NAME=$(basename ${INPUT_NOTEBOOK})
    INPUT_NOTEBOOK_GCS_PATH="${GCS_LOCATION}/staging/${BUILD_TIME}/${NOTEBOOK_NAME}"
    if [[ ! -z ${PARAM_FILE} ]]; then
        INPUT_PARAM_GCS_PATH="${GCS_LOCATION}/staging/${BUILD_TIME}/params.yaml"
        gsutil cp "${PARAM_FILE}" "${INPUT_PARAM_GCS_PATH}"
        PARAM_METADATA=",parameters_file=${INPUT_PARAM_GCS_PATH}"
    fi
    OUTPUT_NOTEBOOK_GCS_FOLDER=$(output_for_mode ${TESTING_MODE} ${GCS_LOCATION})
    OUTPUT_NOTEBOOK_GCS_PATH="${OUTPUT_NOTEBOOK_GCS_FOLDER}/${NOTEBOOK_NAME}"
    gsutil cp "${INPUT_NOTEBOOK}" "${INPUT_NOTEBOOK_GCS_PATH}"
    if [[ $? -eq 1 ]]; then
        echo "Upload to the temp GCS location (${INPUT_NOTEBOOK_GCS_PATH}) of the notebook (${INPUT_NOTEBOOK}) has failed."
        return 1
    fi
    IMAGE_FAMILY="tf-latest-cu100" # or put any required
    ZONE="us-west1-b"
    INSTANCE_NAME="${DEFAULT_NOTEBOOK_EXECUTOR_INSTANCE_NAME}"
    INSTANCE_TYPE="n1-standard-8"
    gcloud compute instances create "${INSTANCE_NAME}" \
            --zone="${ZONE}" \
            --image-family="${IMAGE_FAMILY}" \
            --image-project=deeplearning-platform-release \
            --maintenance-policy=TERMINATE \
            --accelerator="type=nvidia-tesla-${GPU_TYPE},count=${GPU_COUNT}" \
            --machine-type="${INSTANCE_TYPE}" \
            --boot-disk-size=200GB \
            --scopes=https://www.googleapis.com/auth/cloud-platform \
            --metadata="api_key=${API_KEY},testing_mode=${TESTING_MODE},input_notebook=${INPUT_NOTEBOOK_GCS_PATH},output_notebook=${OUTPUT_NOTEBOOK_GCS_FOLDER}${PARAM_METADATA:-}" \
            --metadata-from-file="startup-script=notebook_executor.sh" \
            --quiet
    if [[ $? -eq 1 ]]; then
        echo "Creation of background instance for training has failed."
        return 1
    fi
    wait_till_instance_not_exist "${INSTANCE_NAME}" "${ZONE}"
    echo "execution has been finished, checking result"
    OUTPUT_CONTENTS=$(gsutil ls ${OUTPUT_NOTEBOOK_GCS_FOLDER})
    if [[ $? -ne 0 ]] || grep -q "FAILED" <<< "${OUTPUT_CONTENTS}"; then
        echo "Job failed or unable to get output."
        return 1
    fi
    echo "done"
    return 0
}

execute_notebook_with_gpu demo.ipynb gs://dl-platform-temp/notebook-ci-showcase p100 1