#!/bin/bash
set -x

export PATH=$PATH:/root/bin

KUBECONFIG=/root/.kube/kubeconfig
export KUBECONFIG

start_dockerd() {
    /usr/bin/dockerd \
    	--host=unix:///var/run/docker.sock \
    	--host=tcp://127.0.0.1:2375 \
    	--storage-driver=overlay &>/var/log/docker.log &
    tries=0
    d_timeout=60
    until docker info >/dev/null 2>&1
    do
    	if [ "$tries" -gt "$d_timeout" ]; then
                    cat /var/log/docker.log
    		echo 'Timed out trying to connect to internal docker host.' >&2
    		exit 1
    	fi
            tries=$(( $tries + 1 ))
    	sleep 1
    done    
}


if [[ ! -z $CODEBUILD_BUILD_ID ]]; then
    # in AWS CodeBuild
    echo "found myself in AWS CodeBuild, starting dockerd..."
    start_dockerd
fi


if [[ ! -z $REGION ]]; then
    region=$REGION
    echo "got region=$REGION"
elif [[ ! -z $CODEBUILD_AGENT_ENV_CODEBUILD_REGION ]]; then
    echo "found myself in AWS CodeBuild in $CODEBUILD_AGENT_ENV_CODEBUILD_REGION"
    region=$CODEBUILD_AGENT_ENV_CODEBUILD_REGION
else 
    echo "REGION not defined, trying to lookup from EC2 metadata..."
    region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)
fi

# export AWS_DEFAULT_REGION=${REGION-${CODEBUILD_AGENT_ENV_CODEBUILD_REGION-$region}}
export AWS_DEFAULT_REGION=$region

CLUSTER_NAME=${CLUSTER_NAME-default}

CA_DATA=$(aws eks describe-cluster --name ${CLUSTER_NAME} | jq -r .cluster.certificateAuthority.data)
EKS_ENDPOINT=$(aws eks describe-cluster --name ${CLUSTER_NAME} | jq -r .cluster.endpoint)

sed -i -e \
"s#{CLUSTER_NAME}#${CLUSTER_NAME}#g; \
s#{EKS_ENDPOINT}#${EKS_ENDPOINT}#g; \
s#{CA_DATA}#${CA_DATA}#g;" \
$KUBECONFIG

exec "$@"


