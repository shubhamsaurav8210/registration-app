pipeline {
    agent { label 'jenkins-agent' }

    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    
    environment {
        APP_NAME = "registeration-app-pipeline"
        RELEASE = "1.0.0"
        DOCKER_USER = "shubhamsaurav1999"
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
                    sh "ls -lh target/*.war || echo 'WAR file not found!'"
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
                    sh "docker login -u '${DOCKER_USER}' -p '${DOCKER_PASS}'"

                    def dockerImage = "${IMAGE_NAME}:${IMAGE_TAG}"
                    
                    sh "docker build -t ${dockerImage} -f Dockerfile ."
                    sh "docker tag ${dockerImage} ${IMAGE_NAME}:latest"

                    sh "docker push ${dockerImage}"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }
    }
}
