pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        //EKS_CLUSTER_NAME = 'demo'
        SLACK_CHANNEL = '#buildstatus-jenkins-pipeline'
        SLACK_TOKEN = credentials('jenkins-slack-integration')
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "Checking out code from GitHub"
                    // Clone the code from GitHub
                    //git 'https://github.com/obinnaaliogor/cicd-jenkinspipeline.git'
                }
            }
        }

        stage('Update kube-config') {
            steps {
                script {
                    // Assuming your kube-config file is stored securely in Jenkins credentials
                    //withCredentials([file(credentialsId: 'kube-config-credentials', variable: 'KUBE_CONFIG')]) {
                sh 'aws eks update-kubeconfig --name demo --region us-east-1'
                }
            }
        }

        stage('Install kubectl') {
    steps {
        script {
            sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
            sh 'chmod +x ./kubectl'
            sh 'sudo mv ./kubectl /usr/local/bin/kubectl'
        }
    }
}


        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Verify kubeconfig
                    sh 'kubectl config current-context'

                    // Apply Kubernetes manifests
                    sh 'kubectl apply -f k8s-manifests/'
                }
            }
        }
    }

    post {
        success {
            // Notify success on Slack
            script {
                slackSend(
                    channel: SLACK_CHANNEL,
                    color: 'good',
                    message: "Pipeline succeeded for ${env.JOB_NAME} ${env.BUILD_NUMBER}: ${env.BUILD_URL}",
                    tokenCredentialId: SLACK_TOKEN
                )
            }
        }
        failure {
            // Notify failure on Slack
            script {
                slackSend(
                    channel: SLACK_CHANNEL,
                    color: 'danger',
                    message: "Pipeline failed for ${env.JOB_NAME} ${env.BUILD_NUMBER}: ${env.BUILD_URL}",
                    tokenCredentialId: SLACK_TOKEN
                )
            }
        }
    }
}
