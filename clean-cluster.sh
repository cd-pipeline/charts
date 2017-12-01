#!/usr/bin/env bash

kubectl delete namespace devops || true
kubectl delete namespace charts || true
kubectl delete namespace forsythe-aag-devops || true
kubectl delete namespace forsythe-aag-devops-production || true
kubectl delete namespace forsythe-aag-apps || true
kubectl delete namespace forsythe-aag-apps-production || true
kubectl delete namespace hello-world-service || true
kubectl delete namespace hello-world-service-production || true

helm delete --purge devopsjenkins || true
helm delete --purge sonarqube || true
helm delete --purge nexus || true
helm delete --purge jenkins || true
helm delete --purge clair || true
