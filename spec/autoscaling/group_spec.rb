# encoding: utf-8

autoscaling = Aws::AutoScaling::Client.new

# stub Group
autoscaling.stub_responses(
  :describe_auto_scaling_groups,
  auto_scaling_groups: [{
    auto_scaling_group_name: 'test-group',
    created_time: Time.new,
    launch_configuration_name: 'test-config',
    min_size: 2,
    max_size: 4,
    desired_capacity: 2,
    default_cooldown: 300,
    availability_zones: ['us-east-1a', 'us-east-1b'],
    load_balancer_names: ['test-elb'],
    health_check_type: 'EC2',
    health_check_grace_period: 300,
    instances: [{
      instance_id: 'i-aabbccdd',
      availability_zone: 'us-east-1a',
      lifecycle_state: 'InService',
      health_status: 'Healthy',
      launch_configuration_name: 'test-config',
      protected_from_scale_in: false
    }],
    suspended_processes: [{
      process_name: 'AZRebalance',
      suspension_reason: 'User suspended at 2015-05-25T00:00:00Z'
    }],
    placement_group: 'test-placement-group',
    vpc_zone_identifier: 'subnet-aabbccdd,subnet-ddccbbaa',
    enabled_metrics: [{
      metric: 'GroupTotalInstances',
      granularity: '1Minute'
    }],
    status: nil,
    tags: [{
      resource_id: 'test-group',
      resource_type: 'auto-scaling-group',
      key: 'Name',
      value: 'test-group',
      propagate_at_launch: true
    }],
    termination_policies: %w(
      OldestLaunchConfiguration
      ClosestToNextInstanceHour
    )
  }]
)

# stub Policies (which are exposed by Group anyway)
autoscaling.stub_responses(
  :describe_policies,
  scaling_policies: [{
    auto_scaling_group_name: 'test-group',
    policy_name: 'scale-on-high-cpu',
    scaling_adjustment: 2,
    adjustment_type: 'ChangeInCapacity',
    min_adjustment_step: 0,
    cooldown: 300,
    policy_arn: 'arn:aws:autoscaling:us-east-1:000000000000:scalingPolicy:'\
      'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee:autoScalingGroupName/test-group:'\
      'policyName/scale-on-high-cpu',
    alarms: [{
      alarm_name: 'cpu-utilization',
      alarm_arn: 'arn:aws:cloudwatch:us-east-1:000000000000:alarm:'\
        'cpu-utilization'
    }]
  }]
)

RSpec.describe group = AutoScaling::Group.new('test-group', autoscaling) do
  its(:to_s) { is_expected.to eq 'AutoScaling Group: test-group' }
  its(:launch_configuration) { is_expected.to eq 'test-config' }
  its(:min_size) { is_expected.to eq 2 }
  its(:max_size) { is_expected.to eq 4 }
  its(:desired_capacity) { is_expected.to eq 2 }
  its(:default_cooldown) { is_expected.to eq 300 }
  its(:availability_zones) { is_expected.to eq ['us-east-1a', 'us-east-1b'] }
  its(:load_balancer_names) { is_expected.to eq ['test-elb'] }
  its(:health_check_type) { is_expected.to eq 'EC2' }
  its(:health_check_grace_period) { is_expected.to eq 300 }

  # inconsistent with the above values, but the purpose is to do testing
  its(:instances) do
    instance = group.instances[0]
    expect(instance.instance_id).to eq 'i-aabbccdd'
    expect(instance.availability_zone).to eq 'us-east-1a'
    expect(instance.lifecycle_state).to eq 'InService'
    expect(instance.health_status).to eq 'Healthy'
    expect(instance.launch_configuration_name).to eq 'test-config'
  end

  its(:instance_count) { is_expected.to eq 1 }

  its(:suspended_processes) do
    sp = group.suspended_processes[0]
    expect(sp.process_name).to eq 'AZRebalance'
    expect(sp.suspension_reason).to eq 'User suspended at 2015-05-25T00:00:00Z'
  end

  its(:placement_group) { is_expected.to eq 'test-placement-group' }
  its(:vpc_subnets) { is_expected.to eq ['subnet-aabbccdd', 'subnet-ddccbbaa'] }

  its(:enabled_metrics) do
    em = group.enabled_metrics[0]
    expect(em.metric).to eq 'GroupTotalInstances'
    expect(em.granularity).to eq '1Minute'
  end

  its(:status) { is_expected.to eq nil }

  its(:tags) do
    tag = group.tags[0]
    expect(tag.resource_id).to eq 'test-group'
    expect(tag.resource_type).to eq 'auto-scaling-group'
    expect(tag.value).to eq 'test-group'
    expect(tag.propagate_at_launch).to eq true
  end

  its(:termination_policies) do
    is_expected.to eq %w(OldestLaunchConfiguration ClosestToNextInstanceHour)
  end

  its(:scaling_policies) do
    sp = group.scaling_policies[0]
    expect(sp.auto_scaling_group_name).to eq 'test-group'
    expect(sp.policy_name).to eq 'scale-on-high-cpu'
    expect(sp.scaling_adjustment).to eq 2
    expect(sp.adjustment_type).to eq 'ChangeInCapacity'
    expect(sp.cooldown).to eq 300
    expect(sp.policy_arn).to eq 'arn:aws:autoscaling:us-east-1:000000000000'\
      ':scalingPolicy:aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee:'\
      'autoScalingGroupName/test-group:policyName/scale-on-high-cpu'
    expect(sp.min_adjustment_step).to eq 0

    alarm = sp.alarms[0]
    expect(alarm.alarm_name).to eq 'cpu-utilization'
    expect(alarm.alarm_arn).to eq 'arn:aws:cloudwatch:us-east-1:000000000000'\
      ':alarm:cpu-utilization'
  end
end
