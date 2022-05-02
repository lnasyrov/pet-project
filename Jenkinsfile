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
                    a=$(cat pom.xml | grep SNAPSHOT)
                    ORIGIN_VERSION=$(echo $a | sed 's@<version>@@g' | sed 's@</version>@@g')
                    echo "ORIGIN_VERSION=$ORIGIN_VERSION" > ./version.env
                    VERSION=$(echo $ORIGIN_VERSION | sed "s/SNAPSHOT/$(date +'%Y%m%d_%H%M%S')/g")
                    echo "VERSION=$VERSION" >> ./version.env
                    if [[ $APP_VERSION == 'latest' ]]; then APP_VERSION=$VERSION; fi
                    ./mvnw package
                    echo $CRED | docker login ghcr.io -u lnasyrov --password-stdin
                    docker build . -t ghcr.io/lnasyrov/petclinic:$APP_VERSION
                    docker push ghcr.io/lnasyrov/petclinic:$APP_VERSION
                    '''
                }
            }
        }
        stage('Deploy_test') {
            steps {
                sh '''
                cd spring-petclinic
                a=$(cat pom.xml | grep SNAPSHOT)
                ORIGIN_VERSION=$(echo $a | sed 's@<version>@@g' | sed 's@</version>@@g')
                echo "ORIGIN_VERSION=$ORIGIN_VERSION" > ./version.env
                VERSION=$(echo $ORIGIN_VERSION | sed "s/SNAPSHOT/$(date +'%Y%m%d_%H%M%S')/g")
                echo "VERSION=$VERSION" >> ./version.env
                if $APP_VERSION.equals('latest'){echo $VERSION > ../version.txt}
                '''
                ansiblePlaybook become: true, colorized: true, credentialsId: 'linar-key', disableHostKeyChecking: true, inventory: 'inventory', playbook: 'playbook.yml', extras: "-e @version.txt"
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
                sh '''
                cd spring-petclinic
                a=$(cat pom.xml | grep SNAPSHOT)
                ORIGIN_VERSION=$(echo $a | sed 's@<version>@@g' | sed 's@</version>@@g')
                echo "ORIGIN_VERSION=$ORIGIN_VERSION" > ./version.env
                VERSION=$(echo $ORIGIN_VERSION | sed "s/SNAPSHOT/$(date +'%Y%m%d_%H%M%S')/g")
                echo "VERSION=$VERSION" >> ./version.env
                if [[ $APP_VERSION == 'latest' ]]; then echo VERSION=$VERSION > ../version.txt; fi
                '''
                ansiblePlaybook become: true, colorized: true, credentialsId: 'linar-key', disableHostKeyChecking: true, inventory: 'inventory_prod', playbook: 'playbook.yml', extras: "-e @version.txt"
                }
            }
        }
    }

