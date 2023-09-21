pipeline {

    agent {
        node {
            label 'jenkins-slave-skoleosho'
        }
    }

    tools { go '1.20.6' }

    environment {
        directory = "tf"
    }

    stages {
        stage('Dependency check') {
            steps {
                script {
                    sh "terraform -version"
                    sh "go version"
                    sh "tflint -v"
                }
 
            }
        }
        stage('Terratest') {
            steps {
                script {
                    sh "go test -v -timeout 1h ./..."
                }
            }
        }
        stage('TFLint') {
            steps {
                script {
                    dir("${directory}"){
                        sh "tflint --init"
                        sh "tflint"
                    }
                }
            }
        }  
        stage('Provision Terraform') {
            when {
                expression { params.TF_STATUS == true }
            }
            steps {
                script {
                    dir("${directory}"){
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                    }
                }
            }
        }  
        stage('Destroy Terraform') {
            when {
                expression { params.TF_STATUS == false }
            }
            steps {
                script {
                    dir("${directory}"){
                        sh "terraform destroy --auto-approve"
                    }
                }
            }
        } 
    }
}