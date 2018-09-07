# eks-kubectl-docker
**eks-kubectl-docker** is a docker image with `kubectl` and `aws-iam-authenticator` built in the image.

## Usage
get all the pods from the cluster name `eksdemo`
```
docker run -v $HOME/.aws:/root/.aws \
-e REGION=us-west-2 \
-e CLUSTER_NAME=eksdemo \
-ti pahud/eks-kubectl-docker:latest \
kubectl get po
```
