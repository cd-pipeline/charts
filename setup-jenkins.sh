kubectl create namespace devops || true
kubectl create namespace charts || true
helm delete --purge devopsjenkins || true
sleep 10

helm install --name devopsjenkins -f ./jenkins.yml stable/jenkins --namespace devops
kubectl create secret generic jenkins-maven-settings --from-file=./settings.xml -n devops

kubectl create secret generic regsecret --from-file=./config.json -n charts