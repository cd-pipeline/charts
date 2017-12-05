#!/usr/bin/env bash

kubectl delete namespace devops --ignore-not-found=true
kubectl delete namespace charts --ignore-not-found=true
kubectl delete namespace forsythe-aag-devops --ignore-not-found=true
kubectl delete namespace forsythe-aag-apps --ignore-not-found=true
kubectl delete namespace prod-forsythe-aag-apps --ignore-not-found=true

helm delete --purge devopsjenkins || true
helm delete --purge sonarqube || true
helm delete --purge nexus || true
helm delete --purge jenkins || true
helm delete --purge clair || true
