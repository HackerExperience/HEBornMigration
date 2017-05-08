#!/usr/bin/env groovy

node('elixir') {
  stage('Pre-build') {
    step([$class: 'WsCleanup'])

    env.BUILD_VERSION = sh(script: 'date +%Y.%m.%d%H%M', returnStdout: true).trim()
    def ARTIFACT_PATH = "${env.BRANCH_NAME}/${env.BUILD_VERSION}"

    checkout scm

    sh 'mix local.hex --force'
    sh 'mix local.rebar --force'
    sh 'mix clean'
    sh 'mix deps.get'

    stash name: 'source', useDefaultExcludes: false
  }
}

// node('elixir') {
//   stage('Build [test]') {
//     step([$class: 'WsCleanup'])

//     unstash 'source'

//     withEnv (['MIX_ENV=test']) {
//       sh 'mix compile'
//     }

//     stash 'build-test'
//   }
// }

node('elixir') {
  stage('Build [prod]') {
    step([$class: 'WsCleanup'])

    unstash 'source'

    withEnv (['MIX_ENV=prod']) {
      sh 'mix compile'
<<<<<<< HEAD
      sh 'mix release --env=prod --warnings-as-errors'
=======
>>>>>>> Add Jenkinsfile
    }

    stash 'build-prod'
  }
}
// node('elixir') {
//   stage('Tests') {
//     step([$class: 'WsCleanup'])

//     unstash 'source'
//     unstash 'build-test'

//     withEnv (['MIX_ENV=test']) {
//       // HACK: mix complains if I don't run deps.get again, not sure why
//       sh 'mix deps.get'

//       sh 'mix test'
//     }
//   }
// }

<<<<<<< HEAD
node('elixir') {

  stage('Save artifacts') {
    step([$class: 'WsCleanup'])

    unstash 'build-prod'

    sh "aws s3 cp _build/prod/rel/helix/releases/*/helix.tar.gz s3://he2-releases/helix/${env.BRANCH_NAME}/${env.BUILD_VERSION}.tar.gz --storage-class REDUCED_REDUNDANCY"

  }
=======
node('!master') {
>>>>>>> Add Jenkinsfile

  if (env.BRANCH_NAME == 'master'){
    lock(resource: 'hebornmigration-deployment', inversePrecedence: true) {
      stage('Deploy') {
        sh "ssh deployer deploy heborn_migration prod --branch master"
      }
    }
    milestone()
  }
}
