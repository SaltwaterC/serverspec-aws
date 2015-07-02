# encoding: utf-8

# because RSpec doesn't run tests in order I need to make sure that each
# of the CloudFormation stacks has distinct context
cloudformation1 = Aws::CloudFormation::Client.new
cloudformation1.stub_responses(
  :describe_stacks,
  stacks: [{
    stack_name: 'test-stack1',
    creation_time: Time.new,
    # shouldn't be the case in production, but for stubbing, this defaults to
    # false and it needs to be changed to actually test the code
    disable_rollback: true,
    stack_status: 'CREATE_COMPLETE',
    description: 'test-stack1 description',
    parameters: [{
      parameter_key: 'Param1',
      parameter_value: 'Param1Value',
      use_previous_value: false
    }],
    notification_arns: %w(arn:aws:sns:us-east-1:000000000000:sns-topic),
    timeout_in_minutes: 5,
    capabilities: %w(CAPABILITY_IAM),
    outputs: [{
      output_key: 'test-stack1-output',
      output_value: 'test-stack1-output-value',
      description: 'test-stack1-output description'
    }],
    tags: [{
      key: 'Name',
      value: 'test-stack1'
    }]
  }]
)

cloudformation2 = Aws::CloudFormation::Client.new
cloudformation2.stub_responses(
  :describe_stacks,
  stacks: [{
    stack_name: 'test-stack2',
    creation_time: Time.new,
    stack_status: 'UPDATE_COMPLETE'
  }]
)

cloudformation3 = Aws::CloudFormation::Client.new
cloudformation3.stub_responses(
  :describe_stacks,
  stacks: [{
    stack_name: 'test-stack3',
    creation_time: Time.new,
    stack_status: 'UPDATE_ROLLBACK_COMPLETE'
  }]
)

RSpec.describe stack1 = CloudFormation::Stack.new(
  'test-stack1',
  cloudformation1
) do
  its(:to_s) { is_expected.to eq 'CloudFormation Stack: test-stack1' }

  it { is_expected.to be_rollback_disabled }
  it { is_expected.to be_ok }

  its(:description) { is_expected.to eq 'test-stack1 description' }

  its(:parameters) do
    param = stack1.parameters[0]
    expect(param.parameter_key).to eq 'Param1'
    expect(param.parameter_value).to eq 'Param1Value'
    expect(param.use_previous_value).to eq false
  end

  its(:stack_status) { is_expected.to eq 'CREATE_COMPLETE' }

  notification_arns = %w(arn:aws:sns:us-east-1:000000000000:sns-topic)
  its(:notification_arns) do
    expect(stack1.notification_arns).to eq notification_arns
  end
  its(:timeout_in_minutes) { is_expected.to eq 5 }

  its(:capabilities) { is_expected.to eq %w(CAPABILITY_IAM) }

  its(:outpus) do
    output = stack1.outputs[0]
    expect(output.output_key).to eq 'test-stack1-output'
    expect(output.output_value).to eq 'test-stack1-output-value'
    expect(output.description).to eq 'test-stack1-output description'
  end

  its(:tags) do
    tag = stack1.tags[0]
    expect(tag.key).to eq 'Name'
    expect(tag.value).to eq 'test-stack1'
  end
end

RSpec.describe CloudFormation::Stack.new(
  'test-stack2',
  cloudformation2
) do
  its(:to_s) { is_expected.to eq 'CloudFormation Stack: test-stack2' }
  it { is_expected.to be_ok }
end

RSpec.describe CloudFormation::Stack.new(
  'test-stack3',
  cloudformation3
) do
  its(:to_s) { is_expected.to eq 'CloudFormation Stack: test-stack3' }
  it { is_expected.not_to be_ok }
end
