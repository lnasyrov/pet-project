pipeline {
    agent any

    parameters {
        string(defaultValue: 'latest', description: 'Enter version of the image', name: 'VERSION')
        }

    stages {
        stage('MR_Validation') {
        when {
           not {triggeredBy cause: "UserIdCause", detail: "admin"} 
        } 
            steps {
                    BUILD_TRIGGER_BY=$(curl -k --silent ${BUILD_URL}/api/xml | tr '<' '\n' | egrep '^userId>|^userName>' | sed 's/.*>//g' | sed -e '1s/$/ \//g' | tr '\n' ' ')
                    echo "BUILD_TRIGGER_BY: ${BUILD_TRIGGER_BY}"
                    sh '''
                    cd spring-petclinic
                    ./mvnw package
                    '''
            }
        }
        stage('Build') {
            steps {
                withCredentials([string(credentialsId: 'GitHub_token', variable: 'CRED')]){
                    sh '''
                    cd spring-petclinic
                    ./mvnw package
                    echo $CRED | docker login ghcr.io -u lnasyrov --password-stdin
                    docker build . -t ghcr.io/lnasyrov/petclinic:$VERSION
                    docker push ghcr.io/lnasyrov/petclinic:$VERSION
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                ansiblePlaybook become: true, colorized: true, credentialsId: 'linar-key', disableHostKeyChecking: true, inventory: 'inventory', playbook: 'playbook.yml', extras: "-e VERSION=$VERSION"
                }
            }
        }
    }

