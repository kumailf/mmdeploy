pipeline {
  agent { label 'deploy_linux' }

  parameters {
    text(
        name: 'release_note', 
        defaultValue: 'Release Note 信息如下所示: \n \
Bug-Fixed: \n \
Feature-Added: ', 
        description: 'Release Note的详细信息是什么 ?'
    )

    booleanParam(
        name: 'mmdet', 
        defaultValue: true, 
    )

    booleanParam(
        name: 'mmcls', 
        defaultValue: true, 
    )

    file(
        name: "deploy_property_file", 
        description: "你需要输入的部署环境的设定文件是什么 ?"
    )
  }


  stages {
        stage('Build') { 
            steps {
                echo "start build"
                script {
                    String[] codebase_list = ["mmdet", "mmcls", "mmocr"]
                    String codebase_str = ""
                    for (codebase in codebase_list) {
                        if (params.codebase) {
                            codebase_str = codebase_str + "" + codebase
                        }
                    }
                }
                echo "${codebase_str}"


                echo "Build stage: 选中的构建Module为 : ${params.modulename} ..." 
            }
        }
        stage('Test'){
            steps {
                echo "Test stage: 是否执行自动化测试: ${params.test_skip_flag} ..."
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploy stage: 部署机器的名称 : ${params.deploy_hostname} ..." 
                echo "Deploy stage: 部署连接的密码 : ${params.deploy_password} ..." 
                echo "Deploy stage: Release Note的信息为 : ${params.release_note} ..." 
            }
        }
    }
  }
