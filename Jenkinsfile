pipeline {
    agent any

    environment {
        ENVIRONMENT        = 'dev'            // for now we deploy only to dev
        AWS_DEFAULT_REGION = 'ap-south-1'     // adjust if needed
    }

    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
            }
        }

        stage('Terraform Plan (dev)') {
            steps {
                echo "Running Terraform plan for ${ENVIRONMENT}..."

                // Use AWS credentials stored in Jenkins
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: 'aws-dev-creds']]) {
                    sh '''
                      chmod +x scripts/provision_infra.sh
                      ./scripts/provision_infra.sh "${ENVIRONMENT}" plan
                    '''
                }
            }
        }

        stage('Terraform Apply (dev)') {
            when {
                expression { return env.APPLY_INFRA?.toBoolean() }
            }
            steps {
                echo "Applying Terraform for ${ENVIRONMENT}..."

                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: 'aws-dev-creds']]) {
                    sh '''
                      chmod +x scripts/provision_infra.sh
                      ./scripts/provision_infra.sh "${ENVIRONMENT}" apply
                    '''
                }
            }
        }

        stage('Configure Monitor EC2 (Ansible)') {
            when {
                expression { return env.CONFIGURE_EC2?.toBoolean() }
            }
            steps {
                echo "Configuring monitor EC2 via Ansible..."

                // 1) AWS creds for terraform output
                // 2) SSH key credentials for Ansible
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-dev-creds'],
                    sshUserPrivateKey(credentialsId: 'ansible-ssh-key',
                                      keyFileVariable: 'ANSIBLE_KEY_FILE',
                                      usernameVariable: 'SSH_USER')
                ]) {
                    sh '''
                      chmod +x scripts/configure_ec2.sh
                      export ANSIBLE_SSH_KEY_PATH="$ANSIBLE_KEY_FILE"
                      ./scripts/configure_ec2.sh "${ENVIRONMENT}"
                    '''
                }
            }
        }

        stage('Build Frontend') {
            steps {
                echo "Building React frontend..."

                // Node/npm must be available on Jenkins agent
                sh '''
                  chmod +x scripts/build_frontend.sh
                  ./scripts/build_frontend.sh
                '''
            }
        }

        stage('Deploy Frontend to S3 + CloudFront') {
            steps {
                echo "Deploying frontend to AWS (S3 + CloudFront)..."

                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: 'aws-dev-creds']]) {
                    sh '''
                      chmod +x scripts/deploy_frontend.sh
                      ./scripts/deploy_frontend.sh "${ENVIRONMENT}"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for env: ${ENVIRONMENT}"
        }
        failure {
            echo "Pipeline failed. Check the logs for details."
        }
        always {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-dev-creds']]) {
                sh 'chmod +x scripts/export_tf_outputs.sh'
                sh './scripts/export_tf_outputs.sh dev'
            }
            archiveArtifacts artifacts: 'infra/terraform/envs/dev/terraform-outputs-dev.json', fingerprint: true
        }
    }
}
