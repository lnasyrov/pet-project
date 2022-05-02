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
                    ORIGIN_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout 2>/dev/null)
                    echo "ORIGIN_VERSION=$ORIGIN_VERSION" > ./version.env
                    VERSION=$(echo $ORIGIN_VERSION | sed "s/SNAPSHOT/$(date +'%Y%m%d_%H%M%S')/g")
                    echo "VERSION=$VERSION" >> ./version.env
                    if [[ $APP_VERSION == "latest" && -f version.env ]]; then source version.env; APP_VERSION=$VERSION; fi
                    mvn versions:set -DnewVersion=$VERSION
                    ./mvnw package
                    echo $CRED | docker login ghcr.io -u lnasyrov --password-stdin
                    docker build . -t ghcr.io/lnasyrov/petclinic:$VERSION
                    docker push ghcr.io/lnasyrov/petclinic:$VERSION
                    '''
                }
            }
        }
        stage('Deploy_test') {
            steps {
                ansiblePlaybook become: true, colorized: true, credentialsId: 'linar-key', disableHostKeyChecking: true, inventory: 'inventory', playbook: 'playbook.yml', extras: "-e VERSION=$VERSION"
                }
            }
        stage('Smoke_test') {
            steps {
                sh '''
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
                ansiblePlaybook become: true, colorized: true, credentialsId: 'linar-key', disableHostKeyChecking: true, inventory: 'inventory_prod', playbook: 'playbook.yml', extras: "-e VERSION=$VERSION"
                }
            }
        }
    }

