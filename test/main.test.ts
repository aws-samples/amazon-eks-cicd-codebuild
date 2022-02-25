import { App, Stack } from 'aws-cdk-lib';
import { Template } from 'aws-cdk-lib/assertions';
import { Demo } from '../src/main';

test('Snapshot', () => {
  const app = new App();
  const stack = new Stack(app, 'test');
  new Demo(stack, 'Demo');

  expect(Template.fromStack(stack)).toMatchSnapshot();
});
