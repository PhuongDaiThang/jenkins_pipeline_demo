pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        skipStagesAfterUnstable()
    }

    parameters {
        booleanParam(
            name: 'DEPLOY_LOCAL',
            defaultValue: false,
            description: 'If true, Jenkins will run docker compose locally after build.'
        )
    }

    environment {
        BACKEND_IMAGE_NAME = 'jenkins-demo-backend'
        FRONTEND_IMAGE_NAME = 'jenkins-demo-frontend'
        BACKEND_IMAGE = "${BACKEND_IMAGE_NAME}:${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${FRONTEND_IMAGE_NAME}:${BUILD_NUMBER}"
        COMPOSE_PROJECT_NAME = 'jenkins_demo'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD || true'
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    set +e
                    echo "Java:" && java -version
                    echo "Maven:" && mvn -version
                    echo "Node:" && node --version
                    echo "NPM:" && npm --version
                    echo "Docker:" && docker --version
                    set -e
                '''
            }
        }

        stage('Backend: Test') {
            steps {
                dir('backend') {
                    sh 'mvn -B test'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'backend/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Backend: Package') {
            steps {
                dir('backend') {
                    sh 'mvn -B -DskipTests package'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'backend/target/*.jar', fingerprint: true
                }
            }
        }

        stage('Frontend: Install Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                }
            }
        }

        stage('Frontend: Test') {
            steps {
                dir('frontend') {
                    sh 'npm test -- --run'
                }
            }
        }

        stage('Frontend: Build') {
            steps {
                dir('frontend') {
                    sh 'npm run build'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'frontend/dist/**', fingerprint: true
                }
            }
        }

        stage('Docker: Build Images') {
            steps {
                sh '''
                    docker build -t ${BACKEND_IMAGE} backend
                    docker build -t ${FRONTEND_IMAGE} frontend
                '''
            }
        }

        stage('Deploy Local Demo') {
            when {
                expression { return params.DEPLOY_LOCAL }
            }
            steps {
                sh '''
                    export BACKEND_IMAGE=${BACKEND_IMAGE}
                    export FRONTEND_IMAGE=${FRONTEND_IMAGE}
                    docker compose -f docker-compose.jenkins.yml up -d --remove-orphans
                '''
            }
        }

        stage('Smoke Test') {
            when {
                expression { return params.DEPLOY_LOCAL }
            }
            steps {
                sh '''
                    echo "Waiting for containers..."
                    sleep 12
                    curl -f http://localhost:8080/api/hello
                    curl -f http://localhost:3000
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline finished successfully.'
        }
        failure {
            echo 'Pipeline failed. Open the failed stage log to see the exact command/error.'
        }
        always {
            echo "Build result: ${currentBuild.currentResult}"
        }
    }
}
