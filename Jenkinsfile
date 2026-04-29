pipeline {
    agent any

    environment {
        VM_FRONT = 'sysko@192.168.146.131'
        SSH_KEY = '/var/jenkins_home/.ssh/id_ed25519'
        IMAGE_NAME = 'crisisview-front'
        CONTAINER_NAME = 'front'
        FRONT_PORT = '3000'
        SONAR_TOKEN = 'sqa_781355da3ded9cb6172ec77b17488075d163dbe8'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare reports') {
            steps {
                sh 'mkdir -p reports/tests reports/security reports/quality reports/deploy'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build Next.js') {
            steps {
                sh 'npm run build | tee reports/tests/front-build.log'
            }
        }

        stage('SonarQube analysis') {
            steps {
                sh '''
                    sonar-scanner \
                      -Dsonar.projectKey=crisisview-front \
                      -Dsonar.projectName="CrisisView Front" \
                      -Dsonar.sources=. \
                      -Dsonar.exclusions=node_modules/**,reports/**,.next/** \
                      -Dsonar.host.url=http://sonarqube:9000 \
                      -Dsonar.token=${SONAR_TOKEN} | tee reports/quality/sonarqube-front.log
                '''
            }
        }

        stage('Security audit') {
            steps {
                sh 'npm audit --json > reports/security/npm-audit-front.json || true'
            }
        }

        stage('Docker build') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker save ${IMAGE_NAME}:${BUILD_NUMBER} -o ${IMAGE_NAME}.tar
                '''
            }
        }

        stage('Deploy Front on VM Front') {
            steps {
                sh '''
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no ${IMAGE_NAME}.tar ${VM_FRONT}:/tmp/

                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${VM_FRONT} "
                        docker load -i /tmp/${IMAGE_NAME}.tar &&
                        docker rm -f ${CONTAINER_NAME} || true

                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            -p ${FRONT_PORT}:${FRONT_PORT} \
                            ${IMAGE_NAME}:${BUILD_NUMBER}
                    "
                '''
            }
        }

        stage('Smoke test Front') {
            steps {
                sh '''
                    sleep 5
                    curl -f http://192.168.146.131:3000 | tee reports/deploy/front-smoke-test.log
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'reports/**/*', allowEmptyArchive: true
        }
    }
}