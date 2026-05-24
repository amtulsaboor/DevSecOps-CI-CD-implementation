pipeline {

    agent any

    environment {

        IMAGE_NAME = "amtulsaboor/django-devsecops"
        IMAGE_TAG = "${BUILD_NUMBER}"
        SONAR_URL = 'http://54.196.36.40:9000'
    }

    tools {

        jdk 'JDK17'
    }

    stages {

        stage('Clean Workspace') {

            steps {

                cleanWs()
            }
        }

        stage('Checkout Code') {

            steps {

                git branch: 'main',
                url: 'https://github.com/amtulsaboor/DevSecOps-CI-CD-implementation.git'
            }
        }

        stage('Verify Files') {

            steps {

                sh '''
                pwd
                ls -la
                '''
            }
        }

        stage('Static Code Analysis') {

            steps {

                script {

                    def scannerHome = tool 'sonar-scanner'

                    withCredentials([
                        string(
                            credentialsId: 'sonar token',
                            variable: 'SONAR_TOKEN'
                        )
                    ]) {

                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=django-devsecops \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONAR_URL} \
                        -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {

            steps {

                sh '''
                docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('List Docker Images') {

            steps {

                sh '''
                docker images
                '''
            }
        }

        stage('Trivy Vulnerability Scan') {

            steps {

                sh '''
                trivy image $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Push Image to DockerHub') {

            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                    docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {

            steps {

                sh '''
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                '''
            }
        }

        stage('Verify Kubernetes Deployment') {

            steps {

                sh '''
                kubectl get pods
                kubectl get svc
                kubectl get deployments
                '''
            }
        }
    }

    post {

        success {

            echo 'SUCCESS: Pipeline executed successfully'
        }

        failure {

            echo 'FAILED: Pipeline execution failed'
        }

        always {

            cleanWs()
        }
    }
}
