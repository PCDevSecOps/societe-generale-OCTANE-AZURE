def get_first() {
    node('master') {
        return env.PATH.split(':')[0]
        
    }
}


pipeline {
    agent { label 'windows-slave' }

     options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        lock resource: 'azure-ciap-hosting-dev'
     }

    environment {
        ENVIRONMNT_HOSTING = "dev"
        HOSTING_STACK = "ciaphostingdev"
        HOSTING_URL = "https://azurecoemb.northeurope.cloudapp.azure.com/"
    }

    stages {

        stage('checkout') {
           steps {
                checkout scm
           }
        }

        stage('Create:SocleCIAPHosting') {
            steps {
                ansiColor('xterm') {
                    powershell "./New-SocleCiapHosting.ps1 '${ENVIRONMNT_HOSTING}'"
                }
            }
        }

        stage('Initialize:CIAPHosting') {
            steps {
                ansiColor('xterm') {
                    powershell "./Initialize-AzureCIAPHosting.ps1 '${ENVIRONMNT_HOSTING}'"
                }
            }
        }


        stage('Create:CIAPHosting') {
            steps {
                ansiColor('xterm') {
                    powershell "./New-AzureCIAPHosting.ps1 '${ENVIRONMNT_HOSTING}' '${HOSTING_STACK}'"
                }
            }
        }


        stage('Destroy:CIAPHosting') {
            steps {
                ansiColor('xterm') {
                    powershell "./Remove-AzureCIAPHosting.ps1 '${ENVIRONMNT_HOSTING}' '${HOSTING_STACK}'"
                }
            }
        }


        stage('Destroy:SocleCIAPHosting') {
            steps {
                ansiColor('xterm') {
                    powershell "./Remove-SocleIAPHosting.ps1 '${ENVIRONMNT_HOSTING}' '${HOSTING_STACK}'"
                }
            }
        }





    }

     post {
        always {
          cleanWs()
          echo "finished"
          deleteDir()
        }
     }



}