#!/bin/bash
execute_notebook_with_gpu basic_text_classification.ipynb gs://dl-platform-temp/notebook-ci-showcase p100 1 || exit 1
if [[ ! -f ./notebook.ipynb ]]; then
   exit 1
fi
exit 0
