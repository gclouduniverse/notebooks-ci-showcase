import datetime
import json
import yaml

from google.auth import compute_engine
import googleapiclient.discovery

credentials = compute_engine.Credentials()
build_client = googleapiclient.discovery.build('cloudbuild', 'v1', credentials=credentials)

with open("deploy.yaml", "r") as f:
    base_deploy_request = json.dumps(yaml.load(f))
base_deploy_request["source"] = {
    "storageSource": {
        "bucket": "dl-platform-temp",
        "object": "notebook-ci-showcase/live.tar.gz",
    }
}

def startrun(request):
    deploy_request = base_deploy_request.copy()
    
    # dataset does not have current information, use last year's info
    today = datetime.date.today() - datetime.timedelta(days=365)
    one_week_ago = today - datetime.timedelta(days=7)
    
    deploy_request["substitutions"]["_START_DATE"] = one_week_ago
    deploy_request["substitutions"]["_END_DATE"] = today
    
    response = build_client.projects().builds().create(projectId="deeplearning-platform", body=deploy_request).execute()
