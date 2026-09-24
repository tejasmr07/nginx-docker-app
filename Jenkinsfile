pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        IMAGE_NAME     = "my-html-app"
        SERVICE_NAME   = "my-html-app-service"
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

        stage('Test') {
            steps {
                echo "Smoke-testing a throwaway container before shipping it"
                bat """
                    docker build -t %IMAGE_NAME%:test-%BUILD_NUMBER% .
                    docker rm -f test-%BUILD_NUMBER% 2>nul
                    docker run -d --name test-%BUILD_NUMBER% -p 8099:%CONTAINER_PORT% %IMAGE_NAME%:test-%BUILD_NUMBER%
                    timeout /t 3 /nobreak >nul
                    curl -f http://localhost:8099 >nul 2>&1
                    if errorlevel 1 (
                        docker rm -f test-%BUILD_NUMBER%
                        exit /b 1
                    )
                    docker rm -f test-%BUILD_NUMBER%
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building image %IMAGE_NAME%:%BUILD_NUMBER%"
                bat "docker build -t %IMAGE_NAME%:%BUILD_NUMBER% -t %IMAGE_NAME%:latest ."
            }
        }

        stage('Deploy - Rolling Update') {
            steps {
                echo "Deploying via Docker Swarm rolling update on port %HOST_PORT%..."
                bat """
                    docker service inspect %SERVICE_NAME% >nul 2>&1
                    if errorlevel 1 (
                        docker service create --name %SERVICE_NAME% --replicas 4 --publish %HOST_PORT%:%CONTAINER_PORT% --update-parallelism 1 --update-delay 10s --update-failure-action rollback --rollback-parallelism 1 --rollback-delay 5s %IMAGE_NAME%:%BUILD_NUMBER%
                    ) else (
                        docker service update --image %IMAGE_NAME%:%BUILD_NUMBER% --update-parallelism 1 --update-delay 10s %SERVICE_NAME%
                    )
                """
            }
        }

        stage('Verify') {
            steps {
                bat """
                    timeout /t 5 /nobreak >nul
                    docker service ps %SERVICE_NAME%
                    curl -f http://localhost:%HOST_PORT% >nul 2>&1
                    if errorlevel 1 (
                        echo Health check failed
                        exit /b 1
                    )
                """
            }
        }
    }

    post {
        success {
            echo "✅ Build #${BUILD_NUMBER} succeeded — visit http://localhost:${HOST_PORT}"
        }
        failure {
            echo "❌ Build/Verify failed — rolling back to previous stable version"
            bat "docker service rollback %SERVICE_NAME%"
        }
    }
}             
