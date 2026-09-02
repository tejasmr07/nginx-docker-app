pipeline {
    agent any

    triggers {
        // Jenkins checks GitHub every 2 minutes for new commits (outbound only — no webhook needed)
        pollSCM('H/2 * * * *')
    }

    environment {
        IMAGE_NAME = "my-html-app"
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
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest ."
            }
        }
    }

    post {
        success {
            echo "✅ Build #${BUILD_NUMBER} succeeded — image ${IMAGE_NAME}:latest is ready."
        }
        failure {
            echo "❌ Build failed. Check console output above."
        }
    }
}