@Library('ctsrd-jenkins-scripts') _

properties([disableConcurrentBuilds(),
            disableResume(),
            [$class: 'GithubProjectProperty', displayName: '', projectUrlStr: 'https://github.com/CTSRD-CHERI/cheri-unixbench/'],
            [$class: 'CopyArtifactPermissionProperty', projectNames: '*'],
            [$class: 'JobPropertyImpl', throttle: [count: 3, durationName: 'hour', userBoost: true]],
            pipelineTriggers([githubPush()])
])

jobs = [:]

["mips-nocheri", "mips-hybrid", "mips-purecap"].each { suffix ->
    String name = "unixbench-${suffix}"
    jobs[suffix] = { ->
        cheribuildProject(
            target: name,
            architecture: suffix,
            runTests:false,
            tarballName: "${name}.tar.xz")
    }
}

node("freebsd") {
    dir("mibench") {
        git credentialsId: 'ctsrd-jenkins-new-github-api-key', url: 'https://github.com/CTSRD-CHERI/cheri-unixbench/'
        sh 'git clean  -dfx'
    }
    jobs.each { name, build ->
        echo("${name}");
        dir("mibench") { sh 'git clean  -dfx' }
        build();
    }
}