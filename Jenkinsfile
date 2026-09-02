pipeline {
    agent any

    triggers {
        // Automatically build when Jenkins detects a new commit
        // (works with polling OR a webhook — see notes below)
        pollSCM('H/5 * * * *')   // checks git every 5 minutes
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