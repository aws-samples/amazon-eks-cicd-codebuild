const { AwsCdkTypeScriptApp } = require('projen');
const { Automation } = require('projen-automate-it');

const AUTOMATION_TOKEN = 'PROJEN_GITHUB_TOKEN';

const project = new AwsCdkTypeScriptApp({
  cdkVersion: '1.82.0',
  name: 'eks-cicd-codebuild',
  cdkDependencies: [
    '@aws-cdk/aws-ec2',
    '@aws-cdk/aws-ecr',
    '@aws-cdk/aws-eks',
    '@aws-cdk/aws-iam',
    '@aws-cdk/aws-codebuild',
    '@aws-cdk/aws-codecommit',
    '@aws-cdk/aws-events-targets',
  ],
  dependabot: false,
  deps: ['projen-automate-it'],
  defaultReleaseBranch: 'master',
});

project.addFields({
  resolutions: {
    netmask: '2.0.1',
  },
});


const automation = new Automation(project, { automationToken: AUTOMATION_TOKEN });
automation.autoApprove();
automation.autoMerge();
automation.projenYarnUpgrade();
automation.projenYarnUpgrade('projenYarnUpgradeWithTest', { yarnTest: true });


const common_exclude = ['cdk.out', 'cdk.context.json', 'dockerAssets.d', 'yarn-error.log'];
project.npmignore.exclude('images', ...common_exclude);
project.gitignore.exclude(...common_exclude);


project.synth();
