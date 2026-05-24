pipeline {

    agent any

    environment {
        IMAGE_NAME = "amtulsaboor/django-devsecops"
        IMAGE_TAG = "${BUILD_NUMBER}"
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
                url: 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {

                    sh '''
                    sonar-scanner \
                    -Dsonar.projectKey=django-devsecops \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://<SONAR-IP>:9000 \
                    -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Trivy Vulnerability Scan') {
            steps {
                sh 'trivy image $IMAGE_NAME:$IMAGE_TAG'
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
                    docker login -u $DOCKER_USER -p $DOCKER_PASS
                    docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {

                sh '''
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }

    post {

        success {

            slackSend(
                channel: '#devops',
                message: "SUCCESS: Application Deployed Successfully"
            )
        }

        failure {

            slackSend(
                channel: '#devops',
                message: "FAILED: Pipeline Failed"
            )
        }
    }
}
