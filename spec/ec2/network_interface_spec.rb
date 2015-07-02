# encoding: utf-8

ec2 = Aws::EC2::Client.new
# stub NetworkInterface
ec2.stub_responses(:describe_network_interfaces, network_interfaces: [
  {
    subnet_id: 'subnet-aabbccdd',
    vpc_id: 'vpc-aabbccdd',
    availability_zone: 'us-east-1a',
    description: 'network interface description',
    owner_id: '000000000000000000000',
    requester_id: '111111111111111111111',
    requester_managed: true,
    status: 'in-use',
    mac_address: 'aa:bb:cc:dd:ee:ff',
    private_ip_address: '10.0.0.1',
    private_dns_name: nil,
    source_dest_check: true,
    groups: [
      {
        group_name: 'test-group',
        group_id: 'sg-aabbccdd'
      }
    ],
    attachment: {
      attachment_id: 'eni-attach-aabbccdd',
      instance_id: nil,
      instance_owner_id: 'amazon-elb',
      device_index: 1,
      status: 'attached',
      delete_on_termination: true
    },
    association: nil,
    tag_set: [
      {
        key: 'Name',
        value: 'test-network-interface'
      }
    ],
    private_ip_addresses: [
      {
        private_ip_address: '10.0.0.1',
        private_dns_name: nil,
        primary: true,
        association: nil
      }
    ]
  }
])

RSpec.describe ni = EC2::NetworkInterface.new('eni-aabbccdd', ec2) do
  its(:to_s) { is_expected.to eq 'EC2 NetworkInterface: eni-aabbccdd' }

  it { is_expected.to be_attached }
  it { is_expected.to be_requester_managed }
  it { is_expected.to be_in_use }
  it { is_expected.to be_source_dest_checked }

  its(:subnet_id) { is_expected.to eq 'subnet-aabbccdd' }
  its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }
  its(:availability_zone) { is_expected.to eq 'us-east-1a' }
  its(:description) { is_expected.to eq 'network interface description' }
  its(:owner_id) { is_expected.to eq '000000000000000000000' }
  its(:requester_id) { is_expected.to eq '111111111111111111111' }
  its(:status) { is_expected.to eq 'in-use' }
  its(:mac_address) { is_expected.to eq 'aa:bb:cc:dd:ee:ff' }
  its(:private_ip_address) { is_expected.to eq '10.0.0.1' }
  its(:private_dns_name) { is_expected.to eq nil }

  its(:groups) do
    group = ni.groups[0]
    expect(group.group_name).to eq 'test-group'
    expect(group.group_id).to eq 'sg-aabbccdd'
  end

  its(:attachment) do
    attch = ni.attachment
    expect(attch.attachment_id).to eq 'eni-attach-aabbccdd'
    expect(attch.instance_id).to eq nil
    expect(attch.instance_owner_id).to eq 'amazon-elb'
    expect(attch.device_index).to eq 1
    expect(attch.delete_on_termination).to eq true
  end

  its(:association) { is_expected.to eq nil }

  its(:tags) do
    tag = ni.tags[0]
    expect(tag.key).to eq 'Name'
    expect(tag.value).to eq 'test-network-interface'
  end

  its(:private_ip_addresses) do
    pi = ni.private_ip_addresses[0]
    expect(pi.private_ip_address).to eq '10.0.0.1'
    expect(pi.private_dns_name).to eq nil
    expect(pi.primary).to eq true
    expect(pi.association).to eq nil
  end
end
