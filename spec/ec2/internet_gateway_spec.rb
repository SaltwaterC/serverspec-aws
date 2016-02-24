# encoding: utf-8

ec2 = Aws::EC2::Client.new
# stub InternetGateway
ec2.stub_responses(
  :describe_internet_gateways,
  internet_gateways: [
    {
      attachments: [
        {
          vpc_id: 'vpc-aabbccdd',
          state: 'available'
        }
      ],
      tags: [
        {
          key: 'Name',
          value: 'test-internet-gateway'
        }
      ]
    }
  ]
)

RSpec.describe igw = EC2::InternetGateway.new('igw-aabbccdd', ec2) do
  its(:to_s) { is_expected.to eq 'EC2 InternetGateway: igw-aabbccdd' }
  it { is_expected.to be_available }
  its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }

  its(:attachments) do
    att = igw.attachments[0]
    expect(att.vpc_id).to eq 'vpc-aabbccdd'
    expect(att.state).to eq 'available'
  end

  its(:tags) do
    tag = igw.tags[0]
    expect(tag.key).to eq 'Name'
    expect(tag.value).to eq 'test-internet-gateway'
  end
end
