ec2 = Aws::EC2::Client.new

# rubocop:disable Metrics/MethodLength
def security_group(with_overrides)
  template = {
    owner_id: '000000000000000000000',
    group_name: 'test-group',
    description: 'test-group description',
    ip_permissions: [],
    ip_permissions_egress: [
      {
        ip_protocol: '-1',
        from_port: nil,
        to_port: nil,
        user_id_group_pairs: [],
        ip_ranges: [
          {
            cidr_ip: '0.0.0.0/0'
          }
        ],
        prefix_list_ids: []
      }
    ],
    vpc_id: 'vpc-aabbccdd',
    tags: [
      {
        key: 'Name',
        value: 'test-group'
      }
    ]
  }

  stub_response(template, with_overrides)
end
# rubocop:enable Metrics/MethodLength

# rubocop:disable Metrics/MethodLength
def rule(cidr)
  {
    ip_protocol: 'tcp',
    from_port: 443,
    to_port: 443,
    user_id_group_pairs: [
      {
        user_id: '000000000000000000000',
        group_name: nil,
        group_id: 'sg-ddccbbaa'
      }
    ],
    ip_ranges: [
      {
        cidr_ip: cidr
      }
    ],
    prefix_list_ids: []
  }
end
# rubocop:enable Metrics/MethodLength

RSpec.context 'Security Group allows ingress from anywhere' do
  ec2.stub_responses(
    :describe_security_groups,
    security_groups: [
      security_group(ip_permissions: [rule('0.0.0.0/0')])
    ]
  )

  describe sg = EC2::SecurityGroup.new('sg-aabbccdd', ec2) do
    its(:to_s) { is_expected.to eq 'EC2 SecurityGroup: sg-aabbccdd' }

    its(:owner_id) { is_expected.to eq '000000000000000000000' }
    its(:group_name) { is_expected.to eq 'test-group' }
    its(:description) { is_expected.to eq 'test-group description' }

    its(:ingress_permissions) do
      ingress = sg.ingress_permissions[0]
      expect(ingress.ip_protocol).to eq 'tcp'
      expect(ingress.from_port).to eq 443
      expect(ingress.to_port).to eq 443

      expect(ingress.ip_ranges.size).to eq 1
      expect(ingress.ip_ranges[0].cidr_ip).to eq '0.0.0.0/0'
      expect(ingress.prefix_list_ids).to eq []

      pair = ingress.user_id_group_pairs[0]
      expect(pair.user_id).to eq '000000000000000000000'
      expect(pair.group_name).to eq nil
      expect(pair.group_id).to eq 'sg-ddccbbaa'
    end

    its(:egress_permissions) do
      egress = sg.egress_permissions[0]
      expect(egress.ip_protocol).to eq '-1'
      expect(egress.from_port).to eq nil
      expect(egress.to_port).to eq nil
      expect(egress.user_id_group_pairs).to eq []
      expect(egress.prefix_list_ids).to eq []

      range = egress.ip_ranges[0]
      expect(range.cidr_ip).to eq '0.0.0.0/0'
    end

    its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }

    its(:tags) do
      tag = sg.tags[0]
      expect(tag.key).to eq 'Name'
      expect(tag.value).to eq 'test-group'
    end

    it { should be_accessible_from('0.0.0.0/0') }
  end
end

RSpec.context 'Security Group has no inbound rules' do
  ec2.stub_responses(
    :describe_security_groups,
    security_groups: [
      security_group(ip_permissions: [])
    ]
  )

  describe EC2::SecurityGroup.new('sg-aabbccdd', ec2) do
    it { should_not be_accessible_from('0.0.0.0/0') }
  end
end

RSpec.context 'Security Group allows connection from within a VPC' do
  ec2.stub_responses(
    :describe_security_groups,
    security_groups: [
      security_group(ip_permissions: [rule('10.0.0.1/16')])
    ]
  )

  describe EC2::SecurityGroup.new('sg-aabbccdd', ec2) do
    it { should_not be_accessible_from('0.0.0.0/0') }
    it { should_not be_accessible_from('11.0.0.1/16') }
    it { should be_accessible_from('10.0.0.1/16') }
    it { should be_accessible_from('10.0.0.1/24') }
  end
end
