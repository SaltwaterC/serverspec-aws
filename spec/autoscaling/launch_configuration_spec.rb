# encoding: utf-8

autoscaling = Aws::AutoScaling::Client.new

# stub LaunchConfiguration
autoscaling.stub_responses(
  :describe_launch_configurations,
  launch_configurations: [{
    launch_configuration_name: 'test-config',
    created_time: Time.new,
    instance_monitoring: {
      enabled: true
    },
    ebs_optimized: true,
    associate_public_ip_address: true,
    placement_tenancy: 'default',
    image_id: 'ami-aabbccdd',
    key_name: 'test-key',
    security_groups: ['sg-aabbccdd', 'sg-ddccbbaa'],
    classic_link_vpc_id: 'vpc-aabbccdd',
    classic_link_vpc_security_groups: ['sg-aabbccdd', 'sg-ddccbbaa'],
    user_data: 'Tm90aGluZyBpbnRlcmVzdGluZyBoZXJlLg==',
    instance_type: 't1.micro',
    kernel_id: 'aki-aabbccdd',
    ramdisk_id: 'ari-aabbccdd',
    block_device_mappings: [{
      virtual_name: 'ephemeral0',
      device_name: '/dev/sdf'
    }],
    iam_instance_profile: 'test-instance-profile'
  }]
)

RSpec.describe config = AutoScaling::LaunchConfiguration.new(
  'test-config',
  autoscaling
) do
  its(:to_s) do
    is_expected.to eq 'AutoScaling LaunchConfiguration: test-config'
  end

  it { is_expected.to be_instance_monitored }
  it { is_expected.to be_ebs_optimized }
  it { is_expected.to be_with_public_ip_address }
  it { is_expected.to be_default_tenancy }

  its(:image_id) { is_expected.to eq 'ami-aabbccdd' }
  its(:key_name) { is_expected.to eq 'test-key' }
  its(:security_groups) { is_expected.to eq ['sg-aabbccdd', 'sg-ddccbbaa'] }

  its(:classic_link_vpc_id) { is_expected.to eq 'vpc-aabbccdd' }
  its(:classic_link_vpc_security_groups) do
    is_expected.to eq ['sg-aabbccdd', 'sg-ddccbbaa']
  end

  its(:user_data) { is_expected.to eq 'Tm90aGluZyBpbnRlcmVzdGluZyBoZXJlLg==' }
  its(:instance_type) { is_expected.to eq 't1.micro' }
  its(:kernel_id) { is_expected.to eq 'aki-aabbccdd' }
  its(:ramdisk_id) { is_expected.to eq 'ari-aabbccdd' }

  its(:block_device_mappings) do
    mapping = config.block_device_mappings[0]
    expect(mapping.virtual_name).to eq 'ephemeral0'
    expect(mapping.device_name).to eq '/dev/sdf'
  end

  its(:iam_instance_profile) { is_expected.to eq 'test-instance-profile' }
end
