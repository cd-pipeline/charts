kubectl delete namespace devops || true
sleep 10
kubectl create namespace devops

helm delete --purge devopsjenkins || true
sleep 10

helm install --name devopsjenkins -f ./jenkins.yml stable/jenkins --namespace devops
kubectl create secret generic jenkins-maven-settings --from-file=./settings.xml -n devops