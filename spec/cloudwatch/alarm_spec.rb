# encoding: utf-8

cloudwatch = Aws::CloudWatch::Client.new
cloudwatch.stub_responses(
  :describe_alarms,
  metric_alarms: [
    {
      alarm_description: 'This is the alarm description.',
      state_value: 'OK',
      actions_enabled: true,
      alarm_actions: [
        'arn:aws:sns:us-east-1:000000000000:sns-topic',
        'arn:aws:autoscaling:us-east-1:000000000000:scalingPolicy:aaaaaaaa-'\
        'bbbb-cccc-dddd-eeeeeeeeeeee:autoScalingGroupName/test-group:'\
        'policyName/scale-on-high-cpu'
      ],
      metric_name: 'CPUUtilization',
      namespace: 'AWS/EC2',
      statistic: 'Average',
      dimensions: [{
        name: 'AutoScalingGroupName',
        value: 'test-asg'
      }],
      period: 300,
      evaluation_periods: 1,
      threshold: 75.0,
      comparison_operator: 'GreaterThanOrEqualToThreshold'
    }
  ]
)

RSpec.describe alarm = CloudWatch::Alarm.new('test-alarm', cloudwatch) do
  its(:to_s) { is_expected.to eq 'CloudWatch Alarm: test-alarm' }

  it { is_expected.to be_ok }
  it { is_expected.to be_actions_enabled }

  its(:alarm_description) { is_expected.to eq 'This is the alarm description.' }
  its(:ok_actions) { is_expected.to eq [] }

  its(:alarm_actions) do
    is_expected.to eq [
      'arn:aws:sns:us-east-1:000000000000:sns-topic',
      'arn:aws:autoscaling:us-east-1:000000000000:scalingPolicy:aaaaaaaa-bbbb-'\
      'cccc-dddd-eeeeeeeeeeee:autoScalingGroupName/test-group:policyName/'\
      'scale-on-high-cpu'
    ]
  end

  its(:insufficient_data_actions) { is_expected.to eq [] }
  its(:metric_name) { is_expected.to eq 'CPUUtilization' }
  its(:namespace) { is_expected.to eq 'AWS/EC2' }
  its(:statistic) { is_expected.to eq 'Average' }

  its(:dimensions) do
    dim = alarm.dimensions[0]
    expect(dim.name).to eq 'AutoScalingGroupName'
    expect(dim.value).to eq 'test-asg'
  end

  its(:period) { is_expected.to eq 300 }
  its(:evaluation_periods) { is_expected.to eq 1 }
  its(:threshold) { is_expected.to eq 75.0 }
  its(:comparison_operator) do
    is_expected.to eq 'GreaterThanOrEqualToThreshold'
  end
end
