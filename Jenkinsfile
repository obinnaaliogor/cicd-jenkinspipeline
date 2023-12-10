pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'demo'
        AWS_ROLE_TO_ASSUME = 'arn:aws:iam::612500737416:role/access-cluster-role'
        TERRAFORM_DIR = '.terraform'
        SLACK_CHANNEL = '#buildstatus-jenkins-pipeline'
        SLACK_TOKEN = credentials('jenkins-slack-integration')

        // Global variable to determine apply or destroy
        TF_ACTION = 'apply' // Set this to 'apply' or 'destroy' based on your needs

        // Temporary AWS credentials
        TEMP_AWS_ACCESS_KEY_ID = ''
        TEMP_AWS_SECRET_ACCESS_KEY = ''
        TEMP_AWS_SESSION_TOKEN = ''
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

        stage('Assume Role and Extract AWS Credentials') {
            steps {
                script {
                    def roleCredentials = sh(
                        script: "aws sts assume-role --role-arn ${AWS_ROLE_TO_ASSUME} --role-session-name JenkinsRole --output json",
                        returnStdout: true
                    ).trim()

                    // Set temporary AWS credentials
                    TEMP_AWS_ACCESS_KEY_ID = sh(script: "echo '$roleCredentials' | jq -r .Credentials.AccessKeyId", returnStdout: true).trim()
                    TEMP_AWS_SECRET_ACCESS_KEY = sh(script: "echo '$roleCredentials' | jq -r .Credentials.SecretAccessKey", returnStdout: true).trim()
                    TEMP_AWS_SESSION_TOKEN = sh(script: "echo '$roleCredentials' | jq -r .Credentials.SessionToken", returnStdout: true).trim()

                    if (TEMP_AWS_ACCESS_KEY_ID.isEmpty() || TEMP_AWS_SECRET_ACCESS_KEY.isEmpty() || TEMP_AWS_SESSION_TOKEN.isEmpty()) {
                        error("Failed to extract AWS credentials. Check the AWS CLI and IAM role configurations.")
                    }
                }
            }
        }

        stage('Terraform Apply or Destroy') {
    steps {
        script {
            // Install Terraform
            sh 'terraform init'

            // Determine whether to apply or destroy
            if (env.TF_ACTION == 'apply') {
                echo "Applying Terraform changes"
                // Set AWS environment variables for Terraform
                env.AWS_ACCESS_KEY_ID = TEMP_AWS_ACCESS_KEY_ID
                env.AWS_SECRET_ACCESS_KEY = TEMP_AWS_SECRET_ACCESS_KEY
                env.AWS_SESSION_TOKEN = TEMP_AWS_SESSION_TOKEN

                // Navigate to the Terraform code directory
                    sh 'terraform apply -auto-approve'


            } else if (env.TF_ACTION == 'destroy') {
                // Navigate to the Terraform code directory
                echo "Destroying Terraform resources"
                    sh 'terraform destroy -auto-approve'
            } else {
                error "Invalid TF_ACTION. Should be 'apply' or 'destroy'."
            }
        }
    }
}


        stage('Update kube-config') {
            steps {
                script {
                    // Assuming your kube-config file is stored securely in Jenkins credentials
                    withCredentials([file(credentialsId: 'kube-config-credentials', variable: 'KUBE_CONFIG')]) {
                        sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --kubeconfig kube-config.yaml --role-arn ${AWS_ROLE_TO_ASSUME}"
                    }
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


        stage('Cleanup') {
    steps {
        script {
            // Remove the .terraform directory
            sh "rm -rf ${TERRAFORM_DIR}"

            // Unset the sensitive environment variables
            env.AWS_ACCESS_KEY_ID = null
            env.AWS_SECRET_ACCESS_KEY = null
            env.AWS_SESSION_TOKEN = null

            // Unset other environment variables as needed
            env.TERRAFORM_DIR = null
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
