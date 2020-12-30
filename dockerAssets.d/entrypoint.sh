#!/bin/bash
set -e

# export PATH=$PATH:/root/bin
HOME=/home/kubectl

export KUBECONFIG=$HOME/.kube/kubeconfig

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


if [[ ! -z ${CODEBUILD_BUILD_ID} ]]; then
    # in AWS CodeBuild
    echo "found myself in AWS CodeBuild, starting dockerd..."
    start_dockerd
fi


if [[ ! -z ${AWS_REGION} ]]; then
    region=$AWS_REGION
    echo "[INFO] region=$AWS_REGION"
else 
    echo "REGION not defined, trying to lookup from EC2 metadata..."
    region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)
fi

# export AWS_DEFAULT_REGION=${REGION-${CODEBUILD_AGENT_ENV_CODEBUILD_REGION-$region}}
export AWS_DEFAULT_REGION=$region

CLUSTER_NAME=${CLUSTER_NAME-default}

update_kubeconfig(){
    if [[ -n ${EKS_ROLE_ARN} ]]; then
        echo "[INFO] got EKS_ROLE_ARN=${EKS_ROLE_ARN}, updating kubeconfig with this role"
        aws eks update-kubeconfig --name $CLUSTER_NAME --kubeconfig $KUBECONFIG --role-arn "${EKS_ROLE_ARN}"
    else
        aws eks update-kubeconfig --name $CLUSTER_NAME --kubeconfig $KUBECONFIG    
    fi
}

update_kubeconfig
exec "$@"
