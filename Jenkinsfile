// 镜像仓库地址
def registry = "harbor.scm.local"

// 项目&镜像配置信息
//harbor的namespace
def namespace = "jian"
// app name
def app_name = "go-pipeline"
def image_name = "${registry}/${namespace}/${app_name}:${BUILD_NUMBER}"
// gitlab address
def git_address = "git@192.168.11.161:qujian/spring-mysql-redis-cache.git"

// 认证信息ID
// connection harbor username and password
def docker_registry_auth = "dockerHub"
// gitlab auth info
def git_auth = "64ebab93-e58b-4ced-acc2-993029390661"
// k8s pull image auth info
def secret_name = "registry-secret"
// connection k8s kubeconfig info
def k8s_auth = "kubeconfig"


pipeline {


agent {
    kubernetes {
        label "jenkins-slave"
        yaml """
kind: Pod
metadata:
  name:: jenkins-slave
spec:
  containers:
  - name: jnlp
    resources:
      limits: {}
      requests:
        memory: "256Mi"
        cpu: "100m"
    image: "harbor.scm.local/jian/jenkins-jnlp:v1"
    imagePullPolicy: Always
    volumeMounts:
      - name: docker-cmd
        mountPath: /usr/bin/docker
      - name: docker-sock
        mountPath: /var/run/docker.sock
      - name: maven
        mountPath: /root/.m2/repository
        readOnly: false
      - name: "slave-pv"
        mountPath: "/home/jenkins/agent"
        readOnly: false
  nodeSelector:
    kubernetes.io/os: "linux"
  restartPolicy: "Never"
  volumes:
    - name: docker-cmd
      hostPath:
        path: /usr/bin/docker
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
    #- name: "kube"
    #  hostPath:
    #    path: "/root/.kube"
    - name: "maven"
      persistentVolumeClaim:
        claimName: "maven-pv-claim"
        readOnly: false
    - name: "slave-pv"
      persistentVolumeClaim:
        claimName: "slave-pv-claim"
        readOnly: false
    
"""
}
}

    //parameters {    
    //    gitParameter branch: '', branchFilter: '.*', defaultValue: 'master', description: '选择发布的分支', name: 'Branch', quickFilterEnabled: false, selectedValue: 'NONE', sortMode: 'NONE', tagFilter: '*', type: 'PT_BRANCH'
    //    choice (choices: ['1', '3', '5', '7'], description: '副本数', name: 'ReplicaCount')
    //    choice (choices: ['dev','test','prod'], description: '命名空间', name: 'Namespace')
    //}

    // parameters {
    //    extendedChoice description: '请选择项目(可多选)', multiSelectDelimiter: ',', name: 'PROJECT_LIST', propertyFile: '/home/jenkins/agent/projectList', propertyKey: 'projects', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_CHECKBOX', visibleItemCount: 10
    //     }
    // environment {
    //    projects_list =  "$params.PROJECT_LIST"
    // }

   
    stages {
        stage('UnitTest') {
            steps {
                script {
    //                echo "${env.projects_list}"
                    //sh 'sleep 36000'
                    if( sh(script: 'docker run --rm -v $(pwd):/go/src/gowebdemo -w /go/src/gowebdemo golang:latest /bin/bash -c "/go/src/gowebdemo/rununittest.sh"', returnStatus: true ) != 0 ){
                       currentBuild.result = 'FAILURE'
                    }
                }
                junit '*.xml'
                
                script {
                    if( currentBuild.result == 'FAILURE' ) {
                       sh(script: "echo unit test failed, please fix the errors.")
                       sh "exit 1"
                    }
                }
            }
        }


        stage('Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${docker_registry_auth}", passwordVariable: 'password', usernameVariable: 'username')]) {
            sh """
              docker build -t ${image_name} .
              docker login -u ${username} -p \"${password}\" ${registry}
              docker push ${image_name}
              """
              }
            }
        }


        stage('Deploy') {
            steps {
               echo "image_name: ${image_name}"
               echo "build_number: ${BUILD_NUMBER}"
               sh """
                  if [ -n \"\$(docker ps -q -f name=goweb)\" ]; then
                       docker rm -f goweb 
                  fi
                  echo \"${image_name}\"
                  docker run -d \
                      -p 8088:8088 \
                      --name goweb \
                      --restart=always \
                      \"${image_name}\"
               """
            }
        }
    }

    post {
        failure {
            mail bcc: '', body: "<b>gopro build failed</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset    : 'UTF-8', from: 'szops@dg-mall.com', mimeType: 'text/html', replyTo: '', subject: "ERROR CI: Project name -> ${env.JOB_NAME}", to: "qujian@51-dg.com";
        }
        success {
            mail bcc: '', body: "<b>gopro build success</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: 'szops@dg-mall.com', mimeType: 'text/html', replyTo: '', subject: "SUCCESS CI: Project name -> ${env.JOB_NAME}", to: "qujian@51-dg.com";
        }
    }
}
