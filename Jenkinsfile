pipeline {
    agent { label 'jenkins-agent' }

    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    
    environment {
        APP_NAME = "registeration-app-pipeline"
        RELEASE = "1.0.0"
        DOCKER_USER = "iwphox"
        IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }

    stages {
        stage("Cleanup Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Checkout from SCM") {
            steps {
                script {
                    git branch: 'main', credentialsId: 'github', url: 'https://github.com/shubhamsaurav8210/registration-app.git'
                }
            }
        }

        stage("Build Application") {
            steps {
                script {
                    sh "mvn clean package -DskipTests"
                }
            }
        }

        stage("Verify WAR File") {
            steps {
                script {
                    sh """
                    echo "Checking if WAR file exists..."
                    ls -lh target/*.war || { echo 'WAR file not found! Build might have failed'; exit 1; }
                    """
                }
            }
        }

        stage("Test Application") {
            steps {
                script {
                    sh "mvn test"
                }
            }
        }

        stage("SonarQube Analysis") {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') {
                        sh "mvn sonar:sonar"
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                script {
                    withCredentials([string(credentialsId: 'docker-hub-credentials', variable: 'DOCKER_TOKEN')]) {
                        sh """
                        echo '${DOCKER_TOKEN}' | docker login -u '${DOCKER_USER}' --password-stdin

                        echo "Listing target folder before Docker build..."
                        ls -lh target/

                        def dockerImage="${IMAGE_NAME}:${IMAGE_TAG}"

                        echo "Building Docker Image..."
                        docker build -t ${dockerImage} -f Dockerfile .

                        echo "Tagging Docker Image..."
                        docker tag ${dockerImage} ${IMAGE_NAME}:latest

                        echo "Pushing Docker Image to DockerHub..."
                        docker push ${dockerImage}
                        docker push ${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }
    }
}
