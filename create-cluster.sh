#!/bin/bash
. "./set-params.sh"

gcloud beta container --project "$PROJECT_NAME" clusters create "$KUBERNETES_CLUSTER_NAME" --zone "us-central1-a" --username="admin" --cluster-version "1.8.3-gke.0" --machine-type "n1-highmem-2" --image-type "COS" --disk-size "100" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "2" --network "default" --enable-cloud-logging --no-enable-cloud-monitoring --subnetwork "default" --enable-legacy-authorization

gcloud container clusters get-credentials $KUBERNETES_CLUSTER_NAME --zone us-central1-a --project $PROJECT_NAME

