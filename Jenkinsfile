#!/usr/bin/env groovy

podTemplate(label: 'mypod', containers: [
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.0', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
  ],
  volumes: [
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
  ]) {
    node('mypod') {
        def projectNamespace = "${env.JOB_NAME}".tokenize('/')[0]
        
        stage('Helm Init') {
            container('helm') {
               sh "helm init --client-only"
            }
        }

        stage('Configure Kubernetes') {
            git url: 'https://github.com/cd-pipeline/charts.git'
            container('kubectl') {
                sh "kubectl create namespace ${projectNamespace} || true"
                sh "kubectl delete secret jenkins-maven-settings -n ${projectNamespace} || true"
                sh "kubectl delete secret regsecret -n ${projectNamespace} || true"
                sh "kubectl create secret generic jenkins-maven-settings --from-file=./developer-tools/config/settings.xml -n ${projectNamespace}"
                sh "kubectl create secret generic regsecret --from-file=./devops-tools/config/config.json -n ${projectNamespace}"
                sh "kubectl create -f ./devops-tools/config/maven-pv.yaml -n ${projectNamespace} || true"
                sh "kubectl create -f ./devops-tools/config/maven-pvc.yaml -n ${projectNamespace} || true"
            }
        }

        stage('Install Nexus') {
            git url: 'https://github.com/cd-pipeline/charts.git'

            container('helm') {
               sh "helm delete --purge nexus || true"
               sh "helm install --name nexus -f ./developer-tools/nexus/config/nexus.yml stable/sonatype-nexus --namespace ${projectNamespace}"
            }

            container('kubectl') {
               sh "kubectl get pods -n cd-pipeline"
               waitForAllPodsRunning("${projectNamespace}")
               waitForAllServicesRunning("${projectNamespace}")
            }
        }

        stage('Install SonarQube') {
            git url: 'https://github.com/cd-pipeline/charts.git'

            container('helm') {
               sh "helm delete --purge sonarqube || true"
               sh "helm install --name sonarqube ./helm/charts/sonarqube -f ./developer-tools/sonarqube/config/sonarqube.yml --namespace ${projectNamespace}"
            }

            container('kubectl') {
               sh "kubectl get pods -n ${projectNamespace}"
               waitForAllPodsRunning("${projectNamespace}")
               waitForAllServicesRunning("${projectNamespace}")
            }
        }

        stage('Install Jenkins') {
            git url: 'https://github.com/cd-pipeline/charts.git'

            container('helm') {
               sh "helm delete --purge jenkins || true"
               sh "helm install --name jenkins ./helm/charts/jenkins -f ./developer-tools/jenkins/config/jenkins.yml --namespace ${projectNamespace}"
            }

            container('kubectl') {
               sh "kubectl get pods -n ${projectNamespace}"
               waitForAllPodsRunning("${projectNamespace}")
               waitForAllServicesRunning("${projectNamespace}")
            }
        }

        stage('Summary') {
            container('kubectl') {
               print "All dev tools deployed to ${projectNamespace}"
               nexusEndpoint = sh(returnStdout: true, script: "kubectl --namespace='${projectNamespace}' get svc nexus-sonatype-nexus --no-headers --template '{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}'").trim()
               jenkinsEndpoint = sh(returnStdout: true, script: "kubectl --namespace='${projectNamespace}' get svc jenkins-jenkins --no-headers --template '{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}'").trim()
               sonarEndpoint = sh(returnStdout: true, script: "kubectl --namespace='${projectNamespace}' get svc sonarqube --no-headers --template '{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}'").trim()
               print "Jenkins can be accessed at: http://${jenkinsEndpoint}:8080"
               print "Nexus can be accessed at: http://${nexusEndpoint}:8081"
               print "SonarQube can be accessed at: http://${sonarEndpoint}:8081"
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
                echo 'All services are running'
                break
            }
            sh "kubectl --namespace='${namespace}' get services"
            sleep 10
        }
    }
}
