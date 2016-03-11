# encoding: utf-8

ec2 = Aws::EC2::Client.new

ec2.stub_responses(
  :describe_vpcs, vpcs:
    [
      {
        vpc_id: 'vpc-aabbccdd',
        state: 'available',
        cidr_block: '10.0.0.0/16',
        dhcp_options_id: 'dopt-aabbccdd',
        tags:
        [
          {
            key: 'Name',
            value: 'test-vpc'
          }
        ],
        instance_tenancy: 'default',
        is_default: false
      }
    ]
)

ec2.stub_responses(
  :describe_subnets, subnets:
    [
      {
        subnet_id: 'subnet-aaaaaa',
        vpc_id: 'vpc-aabbccdd',
        cidr_block: '10.0.1.0/24',
        available_ip_address_count: 255,
        availability_zone: 'us-east-1a',
        default_for_az: true,
        map_public_ip_on_launch: true,
        tags: [
          {
            key: 'Name',
            value: 'test-subnet1a'
          }
        ]
      },
      {
        subnet_id: 'subnet-aaaaab',
        vpc_id: 'vpc-aabbccdd',
        cidr_block: '10.0.1.0/24',
        available_ip_address_count: 255,
        availability_zone: 'us-east-1b',
        default_for_az: true,
        map_public_ip_on_launch: true,
        tags: [
          {
            key: 'Name',
            value: 'test-subnet1b'
          }
        ]
      }
    ]
)

RSpec.describe vpc = EC2::VPC.new('vpc-aabbccdd', ec2) do
  describe vpc.subnets do
    its(:to_s) do
      is_expected.to eq 'EC2 Subnets: ["subnet-aaaaaa", "subnet-aaaaab"]'
    end

    it { should be_evenly_spread_across_minimum_az(2) }
  end
end
