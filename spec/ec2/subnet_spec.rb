# encoding: utf-8

ec2 = Aws::EC2::Client.new
# stub Subnet
ec2.stub_responses(:describe_subnets, subnets: [
  {
    state: 'available',
    vpc_id: 'vpc-aabbccdd',
    cidr_block: '10.0.0.0/24',
    available_ip_address_count: 240,
    availability_zone: 'us-east-1a',
    default_for_az: true,
    map_public_ip_on_launch: true,
    tags: [
      {
        key: 'Name',
        value: 'test-subnet'
      }
    ]
  }
])

RSpec.describe subnet = EC2::Subnet.new('subnet-aabbccdd', ec2) do
  its(:to_s) { is_expected.to eq 'EC2 Subnet: subnet-aabbccdd' }

  it { is_expected.to be_available }
  it { is_expected.to be_az_default }
  it { is_expected.to be_with_public_ip_on_launch }

  its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }
  its(:cidr_block) { is_expected.to eq '10.0.0.0/24' }
  its(:available_ip_address_count) { is_expected.to eq 240 }
  its(:availability_zone) { is_expected.to eq 'us-east-1a' }

  its(:tags) do
    tag = subnet.tags[0]
    expect(tag.key).to eq 'Name'
    expect(tag.value).to eq 'test-subnet'
  end
end
