from datetime import datetime, timedelta
import json
import yaml

from google.auth import compute_engine
import googleapiclient.discovery

credentials = compute_engine.Credentials()
build_client = googleapiclient.discovery.build('cloudbuild', 'v1', credentials=credentials)

with open("deploy.yaml", "r") as f:
    base_deploy_request = yaml.load(f)
base_deploy_request["source"] = {
    "storageSource": {
        "bucket": "dl-platform-temp",
        "object": "notebook-ci-showcase/live.tar.gz",
    }
}

def startrun(data, context):
    deploy_request = base_deploy_request.copy()
    
    if data and "today" in data:
        # "today" specified in cloud function invocation, use defined date
        today = datetime.strptime(data["today"], "%Y-%m-%d")
    else:
        # dataset does not have current information, use last year's info
        today = datetime.fromisoformat(context.timestamp) - timedelta(days=365)

    one_week_ago = today - timedelta(days=7)
    
    deploy_request["substitutions"]["_START_DATE"] = "{:%Y-%m-%d}".format(one_week_ago)
    deploy_request["substitutions"]["_END_DATE"] = "{:%Y-%m-%d}".format(today)
    
    response = build_client.projects().builds().create(projectId="deeplearning-platform", body=deploy_request).execute()
    return str(response)
