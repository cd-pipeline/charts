#!/bin/bash

. "./set-params.sh"


gcloud container clusters  --project "$PROJECT_NAME" delete $KUBERNETES_CLUSTER_NAME --zone "us-central1-a" -q
