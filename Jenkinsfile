pipeline {
    agent any

    parameters {
        string(defaultValue: 'latest', description: 'Enter version of the image', name: 'APP_VERSION')
        }

    stages {
        stage('Build') {
            steps {
                withCredentials([string(credentialsId: 'GitHub_token', variable: 'CRED')]){
                    sh '''
                    cd spring-petclinic
                    echo "some message"
                    a=$(cat pom.xml | grep SNAPSHOT)
                    ORIGIN_VERSION=$(echo $a | sed 's@<version>@@g' | sed 's@</version>@@g')
                    VERSION=$(echo $ORIGIN_VERSION | sed "s/SNAPSHOT/$(date +'%Y%m%d_%H%M%S')/g")
                    if [[ $APP_VERSION == 'latest' ]]; then echo $VERSION > ../version.txt; else echo $APP_VERSION > ../version.txt; fi
                    STG_VERSION=$(cat ../version.txt)
                    ./mvnw package
                    echo $CRED | docker login ghcr.io -u lnasyrov --password-stdin
                    docker build . -t ghcr.io/lnasyrov/petclinic:$STG_VERSION
                    docker push ghcr.io/lnasyrov/petclinic:$STG_VERSION
                    '''
                }
            }
        }
        stage('Deploy_test') {
            steps {
                script {
                APP_VERSION = readFile('version.txt').trim()
                }
                ansiblePlaybook become: true, colorized: true, credentialsId: 'linar-key', disableHostKeyChecking: true, inventory: 'inventory', playbook: 'playbook.yml', extras: "-e VERSION=$APP_VERSION"
                }
            }
        stage('Smoke_test') {
            steps {
                sh '''
                sleep 30
                ip=$(cat inventory | awk '{ print $1 }' | grep -E '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')
                sh test.sh http://$ip:8080/
                '''
                }
            }
        stage('Deploy_prod') {
            // input{
            //   message "Do you want to proceed for production deployment?"  //strings for continious delivery
            // }
            steps {
                script {
                APP_VERSION = readFile('version.txt').trim()
                }
                ansiblePlaybook become: true, colorized: true, credentialsId: 'linar-key', disableHostKeyChecking: true, inventory: 'inventory_prod', playbook: 'playbook.yml', extras: "-e VERSION=$APP_VERSION"
                }
            }
        }
    }

