pipeline {
    agent any

    triggers {
        // Jenkins checks GitHub every 2 minutes for new commits (outbound only — no webhook needed)
        pollSCM('H/2 * * * *')
    }

    environment {
        IMAGE_NAME     = "my-html-app"
        CONTAINER_NAME = "nginx-html-app"
        HOST_PORT      = "8082"
        CONTAINER_PORT = "80"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Pulling latest code from Git..."
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building image ${IMAGE_NAME}:${BUILD_NUMBER}"
                bat "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying container on port ${HOST_PORT}..."
                bat """
                    docker stop ${CONTAINER_NAME}
                    docker rm ${CONTAINER_NAME}
                    docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} --restart unless-stopped ${IMAGE_NAME}:latest
                """
            }
        }
    }

    post {
        success {
            echo "✅ Build #${BUILD_NUMBER} succeeded — visit http://localhost:${HOST_PORT}"
        }
        failure {
            echo "❌ Build failed. Check console output above."
        }
    }
}