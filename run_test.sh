#!/bin/bash

wget https://github.com/gclouduniverse/JupyterNotebooksDevelopmentManifesto/blob/master/3_self_contained/enable_notebook_submission.sh .
chmod +x enable_notebook_submission.sh
./enable_notebook_submission.sh

execute_notebook_with_gpu basic_text_classification.ipynb gs://dl-platform-temp/notebook-ci-showcase p100 1 || exit 1
if [[ ! -f ./notebook.ipynb ]]; then
   exit 1
fi
exit 0
