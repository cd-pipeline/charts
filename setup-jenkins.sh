kubectl delete namespace cd-pipeline || true
kubectl create namespace cd-pipeline

helm delete --purge jenkins || true
helm install --name jenkins -f ./config/jenkins.yml stable/jenkins --namespace cd-pipeline
kubectl create secret generic jenkins-maven-settings --from-file=./settings.xml -n cd-pipeline