#!/bin/bash
set -x

export PATH=$PATH:/root/bin

KUBECONFIG=/root/.kube/kubeconfig
export KUBECONFIG

if [[ -z $REGION ]]; then
    echo "REGION not defined, trying to lookup from EC2 metadata..."
    region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)
else 
    echo "got region=$REGION"
fi
export AWS_DEFAULT_REGION=${REGION-$region}

CLUSTER_NAMEi=${CLUSTER_NAME-default}

CA_DATA=$(aws eks describe-cluster --name ${CLUSTER_NAME} | jq -r .cluster.certificateAuthority.data)
EKS_ENDPOINT=$(aws eks describe-cluster --name ${CLUSTER_NAME} | jq -r .cluster.endpoint)

sed -i -e \
"s#{CLUSTER_NAME}#${CLUSTER_NAME}#g; \
s#{EKS_ENDPOINT}#${EKS_ENDPOINT}#g; \
s#{CA_DATA}#${CA_DATA}#g;" \
$KUBECONFIG

exec "$@"


