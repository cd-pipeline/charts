kubectl delete namespace cd-pipeline || true
sleep 10
kubectl create namespace cd-pipeline

kubectl delete namespace production || true
sleep 10
kubectl create namespace production

helm delete --purge jenkins || true
sleep 10

helm install --name jenkins -f ./config/jenkins.yml stable/jenkins --namespace cd-pipeline
kubectl create secret generic jenkins-maven-settings --from-file=./settings.xml -n cd-pipeline

kubectl create secret docker-registry regsecret --docker-server=quay.io/cd_pipeline/cloud-repository --docker-username=cd-pipeline --docker-password=$forsythe17@! --docker-email=akalinovski@forsythe.com -n cd-pipeline
