#!/usr/bin/env bash

kubectl delete namespace devops --ignore-not-found=true
sleep 20

kubectl create namespace devops

helm init
helm delete --purge devopsjenkins &> /dev/null
sleep 20

echo "Installing Jenkins... Please wait"

source ./env.sh
envsubst < ./devops-tools/jenkins/config/jenkins.yml > ./jenkins-config.yml

helm install --name devopsjenkins ./helm/charts/jenkins -f ./jenkins-config.yml --namespace devops

echo 'Waiting for Jenkins to be up and running...'
PENDING_SERVICES="pending"
while [ "$PENDING_SERVICES" != "" ]
do
  sleep 10s
  PENDING_SERVICES=$(kubectl --namespace='devops' get services --no-headers | grep "pending")
done

export SERVICE_IP=$(kubectl get svc --namespace devops devopsjenkins-jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Done. Jenkins Address: http://$SERVICE_IP:8080"
echo "Password:"
printf $(kubectl get secret --namespace devops devopsjenkins-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo