#!/usr/bin/env bash
kubectl delete namespace devops || true
sleep 20

kubectl create namespace devops || true

helm init
helm delete --purge devopsjenkins || true
sleep 20

helm install --name devopsjenkins ./helm/charts/jenkins -f ./devops-tools/jenkins/config/jenkins.yml --namespace devops