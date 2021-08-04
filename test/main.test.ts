import '@aws-cdk/assert/jest';
import { App, Stack } from '@aws-cdk/core';
import { Demo } from '../src/main';

test('Snapshot', () => {
  const app = new App();
  const stack = new Stack(app, 'test');
  new Demo(stack, 'Demo');

  expect(stack).not.toHaveResource('AWS::S3::Bucket');
  expect(app.synth().getStackArtifact(stack.artifactId).template).toMatchSnapshot();
});
