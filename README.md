## Note
For **latest** version of this project please take a look [here](https://github.com/GoogleCloudPlatform/ai-platform-samples/tree/master/notebooks/tools/notebooks-ci-showcase)

# Fully Configured Example of DL Pipeline build around Jupyter Notebooks

This repository includes a fully functional pipeline for cleaning tranig and deployment for DL Model. 

The goal of this repository is to showcase what can be built using notebook-centric development practices, and we aim for it to be a reference implementation for those who want to develop similar systems on Google Cloud. For the purposes of this example, we have created two notebooks for cleaning data and for training. 

## GCP Services

In our setup, we have leveraged the following services/products of [Google Cloud Platform](https://cloud.google.com/):

Core services:
* [AI Platform Notebooks](https://cloud.google.com/ml-engine/docs/notebooks/) - for Notebooks creation
* [Cloud Deep Learning Container](https://cloud.google.com/ai-platform/deep-learning-containers/) 
* [Cloud Build](https://cloud.google.com/cloud-build/) 
* [Cloud Storage (GCS)](https://cloud.google.com/storage/)
* GitHub (or [Cloud Source Repository](https://cloud.google.com/source-repositories/))
