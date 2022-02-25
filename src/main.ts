import * as path from 'path';
import {
  Stack, App, CfnOutput,
  aws_codebuild as codebuild,
  aws_codecommit as codecommit,
  aws_ec2 as ec2,
  aws_ecr as ecr,
  aws_eks as eks,
  aws_events_targets as targets,
  aws_iam as iam,
} from 'aws-cdk-lib';
import { Construct } from 'constructs';

export class Demo extends Construct {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    const vpc = getOrCreateVpc(this);
    const cluster = new eks.Cluster(this, 'Cluster', {
      vpc,
      version: eks.KubernetesVersion.V1_20,
      defaultCapacity: 2,
    });

    const stackName = Stack.of(this).stackName;

    const ecrRepo = new ecr.Repository(this, 'EcrRepo');

    const repository = new codecommit.Repository(this, 'CodeCommitRepo', {
      repositoryName: `${stackName}-repo`,
    });

    const project = new codebuild.Project(this, 'MyProject', {
      projectName: `${stackName}`,
      source: codebuild.Source.codeCommit({ repository }),
      environment: {
        buildImage: codebuild.LinuxBuildImage.fromAsset(this, 'CustomImage', {
          directory: path.join(__dirname, '../dockerAssets.d'),
        }),
        privileged: true,
      },
      environmentVariables: {
        CLUSTER_NAME: {
          value: `${cluster.clusterName}`,
        },
        ECR_REPO_URI: {
          value: `${ecrRepo.repositoryUri}`,
        },
      },
      buildSpec: codebuild.BuildSpec.fromObject({
        version: '0.2',
        phases: {
          pre_build: {
            commands: [
              'env',
              'export TAG=${CODEBUILD_RESOLVED_SOURCE_VERSION}',
              'export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output=text)',
              '/usr/local/bin/entrypoint.sh',
              'echo Logging in to Amazon ECR',
              'aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com',
            ],
          },
          build: {
            commands: [
              'cd flask-docker-app',
              'docker build -t $ECR_REPO_URI:$TAG .',
              'docker push $ECR_REPO_URI:$TAG',
            ],
          },
          post_build: {
            commands: [
              'kubectl get no',
              'kubectl set image deployment flask-deployment flask=$ECR_REPO_URI:$TAG',
            ],
          },
        },
      }),
    });

    repository.onCommit('OnCommit', {
      target: new targets.CodeBuildProject(project),
    });

    ecrRepo.grantPullPush(project.role!);
    cluster.awsAuth.addMastersRole(project.role!);
    project.addToRolePolicy(new iam.PolicyStatement({
      actions: ['eks:DescribeCluster'],
      resources: [`${cluster.clusterArn}`],
    }));

    new CfnOutput(this, 'CodeCommitRepoName', { value: `${repository.repositoryName}` });
    new CfnOutput(this, 'CodeCommitRepoArn', { value: `${repository.repositoryArn}` });
    new CfnOutput(this, 'CodeCommitCloneUrlSsh', { value: `${repository.repositoryCloneUrlSsh}` });
    new CfnOutput(this, 'CodeCommitCloneUrlHttp', { value: `${repository.repositoryCloneUrlHttp}` });
  }
}

const app = new App();

const env = {
  region: process.env.CDK_DEFAULT_REGION || 'us-east-1',
  account: process.env.CDK_DEFAULT_ACCOUNT,
};

const stack = new Stack(app, 'eks-cicd-codebuild-stack', { env });

new Demo(stack, 'demo');

function getOrCreateVpc(scope: Construct): ec2.IVpc {
  // use an existing vpc or create a new one
  return scope.node.tryGetContext('use_default_vpc') === '1'
    || process.env.CDK_USE_DEFAULT_VPC === '1' ? ec2.Vpc.fromLookup(scope, 'Vpc', { isDefault: true }) :
    scope.node.tryGetContext('use_vpc_id') ?
      ec2.Vpc.fromLookup(scope, 'Vpc', { vpcId: scope.node.tryGetContext('use_vpc_id') }) :
      new ec2.Vpc(scope, 'Vpc', { maxAzs: 3, natGateways: 1 });
}
