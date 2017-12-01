export jenkins_pod=$(kubectl get pods -n devops | grep jenkins | awk '{print $1;}')
kubectl port-forward $jenkins_pod 8080 -n devops