![](https://codebuild.us-west-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiQStpdGJMVDZ6b3BWODRiOGYvanJhTFhsNnZCVnExS1VxcnRManFSeWNjVndrVGRpV1g0QktxNWZONXZsU05WL3luU1ZQbC9jdnh4TWFKbXJ3emQ2Z1BFPSIsIml2UGFyYW1ldGVyU3BlYyI6IjNmUk00TERiZGlDNisvOEsiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
# eks-kubectl-docker
**eks-kubectl-docker** is a docker image with `kubectl` and `aws-iam-authenticator` built in the image.

# Usage
get all the pods from the cluster name `eksdemo`
```bash
docker run -v $HOME/.aws:/root/.aws \
-e REGION=us-west-2 \
-e CLUSTER_NAME=eksdemo \
-ti pahud/eks-kubectl-docker:latest \
kubectl get po
```



# CodeBuild support

You can use `pahud/eks-kubectl-docker` as the custom image for your CodeBuild environment.



## Howto

Create an IAM Role for CodeBuild with a custom policies

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:*:*:cluster/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "eks:ListClusters",
            "Resource": "*"
        }
    ]
}
```



edit `aws-auth` ConfigMap and add the created role Arn in the `system:masters` group

```
kubectl edit -n kube-system cm/aws-auth
```

![](images/01.png)



In CodeBuild, create a project and specify `pahud/eks-kubectl-docker` as the custom image.

![](images/02.png)

Specify the IAM Service role you just created in the previous step

![](images/03.png)



Create `buildspec.yaml` or just specify `/root/bin/entrypoint.sh kubectl get po` as the build command

![](images/04.png)



Specify the required environment variables. In this case, we specify our region in `us-west-2` with Amazon EKS cluster name as `eksdemo`

![](images/05.png)



start the build and see the build logs. Check the output of your `kubectl get po` commands.

![](images/06.png)

