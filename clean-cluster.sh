#!/usr/bin/env bash

kubectl delete namespace devops || true
kubectl delete namespace charts || true
kubectl delete namespace forsythe-aag-devops || true
kubectl delete namespace forsythe-aag-apps || true
kubectl delete namespace prod-forsythe-aag-apps || true

helm delete --purge devopsjenkins || true
helm delete --purge sonarqube || true
helm delete --purge nexus || true
helm delete --purge jenkins || true
helm delete --purge clair || true
