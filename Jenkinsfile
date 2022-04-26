pipeline {
    agent any

    parameters {
        string(defaultValue: 'latest', description: 'Enter version of the image', name: 'VERSION')
        }

    stages {
        stage('MR_Validation') {
        when {
          environment name: 'IS_PULL_REQUEST', value: 'true'
        } 
            steps {
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

