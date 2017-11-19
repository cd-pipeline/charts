# charts
Helm Charts for CI/CD pipeline

kubectl delete namespace cd-pipeline || true

kubectl create namespace cd-pipeline || true

helm delete --purge sonarqube || true

Install sonarqube:
helm install --name sonarqube ./sonarqube/ --namespace cd-pipeline
