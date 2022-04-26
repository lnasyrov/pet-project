pipeline {
    agent any

    stages {
        stage('MR_Validation') {
            when {
        branch 'main'
            }
            steps {
                withCredentials([string(credentialsId: 'GitHub_token', variable: 'CRED')]){
                    sh '''
                    cd spring-petclinic
                    ./mvnw package
                    '''
                }
            }
        }
        stage('Build') {
            steps {
                withCredentials([string(credentialsId: 'GitHub_token', variable: 'CRED')]){
                    sh "pwd"
                    sh "ls -al"
                    sh '''
                    cd spring-petclinic
                    ./mvnw package
                    echo $CRED | docker login ghcr.io -u lnasyrov --password-stdin
                    docker build . -t ghcr.io/lnasyrov/petclinic:latest
                    docker push ghcr.io/lnasyrov/petclinic:latest
                    '''
                }
            }
        }
        stage('Deploy') {
            agent { label 'ansible-master' }
            steps {
                withCredentials([string(credentialsId: 'GitHub_token', variable: 'CRED')]){
                    sh '''
                    export CR_PAT=$CRED
                    ansible-playbook /home/ec2-user/playbook.yml
                    echo "CONGRATULATION!!!"
                    '''
                }
            }
        }
    }
}

