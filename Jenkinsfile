#!/usr/bin/env groovy

podTemplate(label: 'mypod', containers: [
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.0', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
  ],
  volumes: [
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
  ]) {
    node('mypod') {
        stage('Helm Init') {
            container('helm') {
               sh "helm init --client-only"
            }
        }

        stage('Configure Kubernetes') {
            git url: 'https://github.com/cd-pipeline/charts.git'
            container('kubectl') {
                sh "kubectl delete secret jenkins-maven-settings -n cd-pipeline || true"
                sh "kubectl create secret generic jenkins-maven-settings --from-file=./settings.xml -n cd-pipeline"
            }
        }

        stage('Install Nexus') {
            git url: 'https://github.com/cd-pipeline/charts.git'

            container('helm') {
               sh "helm delete --purge nexus || true"
               sh "helm install --name nexus -f ./config/nexus.yml stable/sonatype-nexus --namespace cd-pipeline"
            }

            container('kubectl') {
               sh "kubectl get pods -n cd-pipeline"
               waitForAllPodsRunning('cd-pipeline')
               waitForAllServicesRunning('cd-pipeline')
            }
        }

        stage('Install SonarQube') {
            git url: 'https://github.com/cd-pipeline/charts.git'

            container('helm') {
               sh "helm delete --purge sonarqube || true"
               sh "helm install --name sonarqube ./sonarqube -f ./config/sonarqube.yml --namespace cd-pipeline"
            }

            container('kubectl') {
               sh "kubectl get pods -n cd-pipeline"
               waitForAllPodsRunning('cd-pipeline')
               waitForAllServicesRunning('cd-pipeline')
            }
        }

        stage('Install Clair') {
            git url: 'https://github.com/coreos/clair'
            container('helm') {
                sh "helm install ./helm/clair -f ./contrib/helm/values.yaml"
            }
        }
    }
}

def waitForAllPodsRunning(String namespace) {
    timeout(60) {
        while (true) {
            podsStatus = sh(returnStdout: true, script: "kubectl --namespace='${namespace}' get pods --no-headers").trim()
            def notRunning = podsStatus.readLines().findAll { line -> !line.contains('Running') }
            if (notRunning.isEmpty()) {
                echo 'All pods are running'
                break
            }
            sh "kubectl --namespace='${namespace}' get pods"
            sleep 10
        }
    }
}

def waitForAllServicesRunning(String namespace) {
    timeout(60) {
        while (true) {
            servicesStatus = sh(returnStdout: true, script: "kubectl --namespace='${namespace}' get services --no-headers").trim()
            def notRunning = servicesStatus.readLines().findAll { line -> line.contains('pending') }
            if (notRunning.isEmpty()) {
                echo 'All pods are running'
                break
            }
            sh "kubectl --namespace='${namespace}' get services"
            sleep 10
        }
    }
}
