# encoding: utf-8

ec2 = Aws::EC2::Client.new
# stub VPC
ec2.stub_responses(
  :describe_vpcs, vpcs: [
    {
      vpc_id: 'vpc-aabbccdd',
      state: 'available',
      cidr_block: '10.0.0.0/16',
      dhcp_options_id: 'dopt-aabbccdd',
      tags: [
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

RSpec.describe vpc = EC2::VPC.new('vpc-aabbccdd', ec2) do
  its(:to_s) { is_expected.to eq 'EC2 VPC: vpc-aabbccdd' }

  it { is_expected.to be_available }
  it { is_expected.not_to be_default }
  it { is_expected.to be_default_tenancy }

  its(:cidr_block) { is_expected.to eq '10.0.0.0/16' }
  its(:dhcp_options_id) { is_expected.to eq 'dopt-aabbccdd' }

  its(:tags) do
    tag = vpc.tags[0]
    expect(tag.key).to eq 'Name'
    expect(tag.value).to eq 'test-vpc'
  end
end
