helm delete --purge jenkins || true
helm install --name jenkins -f ./config/jenkins.yml stable/jenkins --namespace cd-pipeline