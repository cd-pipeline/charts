#!/usr/bin/env bash
kubectl delete namespace devops || true
sleep 20

kubectl create namespace devops || true

helm init
helm delete --purge devopsjenkins || true
sleep 20

helm install --name devopsjenkins -f ./jenkins/config/jenkins.yml stable/jenkins --namespace devops