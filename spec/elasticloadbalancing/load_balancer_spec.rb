elb1 = Aws::ElasticLoadBalancing::Client.new
elb1.stub_responses(
  :describe_load_balancers,
  load_balancer_descriptions: [
    {
      dns_name: 'internal-test-elb1-000000000.us-east-1.elb.amazonaws.com',
      canonical_hosted_zone_name: nil,
      canonical_hosted_zone_name_id: 'AAAAAAAAAAAAAA',
      listener_descriptions: [
        {
          listener: {
            protocol: 'TCP',
            load_balancer_port: 80,
            instance_protocol: 'TCP',
            instance_port: 80,
            ssl_certificate_id: nil
          },
          policy_names: []
        }
      ],
      policies: {},
      availability_zones: ['us-east-1a', 'us-east-1b'],
      subnets: ['subnet-aabbccdd', 'subnet-ddccbbaa'],
      vpc_id: 'vpc-aabbccdd',
      instances: [
        {
          instance_id: 'i-aabbccdd'
        },
        {
          instance_id: 'i-ddccbbaa'
        }
      ],
      health_check: {
        target: 'HTTP:80/health_check',
        interval: 10,
        timeout: 5,
        unhealthy_threshold: 2,
        healthy_threshold: 5
      },
      source_security_group: {
        owner_alias: '111111111111',
        group_name: 'test-group'
      },
      security_groups: ['sg-aabbccdd', 'sg-ddccbbaa'],
      scheme: 'internal'
    }
  ]
)

elb2 = Aws::ElasticLoadBalancing::Client.new
elb2.stub_responses(
  :describe_load_balancers,
  load_balancer_descriptions: [
    {
      scheme: 'internet-facing'
    }
  ]
)

RSpec.describe elb1 = ElasticLoadBalancing::LoadBalancer.new(
  'test-elb1',
  elb1
) do
  its(:to_s) do
    is_expected.to eq 'ElasticLoadBalancing LoadBalancer: test-elb1'
  end

  it { is_expected.to be_internal }

  its(:dns_name) do
    is_expected.to eq 'internal-test-elb1-000000000.us-east-1.elb.amazonaws.com'
  end

  its(:canonical_hosted_zone_name) { is_expected.to eq nil }
  its(:canonical_hosted_zone_name_id) { is_expected.to eq 'AAAAAAAAAAAAAA' }

  its(:listeners) do
    listen = elb1.listeners[0].listener
    expect(listen.protocol).to eq 'TCP'
    expect(listen.load_balancer_port).to eq 80
    expect(listen.instance_protocol).to eq 'TCP'
    expect(listen.instance_port).to eq 80
    expect(listen.ssl_certificate_id).to eq nil
    expect(elb1.listeners[0].policy_names).to eq []
  end

  its(:policies) do
    pol = elb1.policies
    expect(pol.app_cookie_stickiness_policies).to eq []
    expect(pol.lb_cookie_stickiness_policies).to eq []
    expect(pol.other_policies).to eq []
  end

  its(:backend_server_descriptions) { is_expected.to eq [] }
  its(:availability_zones) { is_expected.to eq ['us-east-1a', 'us-east-1b'] }
  its(:subnets) { is_expected.to eq ['subnet-aabbccdd', 'subnet-ddccbbaa'] }
  its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }
  its(:instances) { is_expected.to eq ['i-aabbccdd', 'i-ddccbbaa'] }

  its(:health_check) do
    hc = elb1.health_check
    expect(hc.target).to eq 'HTTP:80/health_check'
    expect(hc.interval).to eq 10
    expect(hc.timeout).to eq 5
    expect(hc.unhealthy_threshold).to eq 2
    expect(hc.healthy_threshold).to eq 5
  end

  its(:source_security_group) do
    ssg = elb1.source_security_group
    expect(ssg.owner_alias).to eq '111111111111'
    expect(ssg.group_name).to eq 'test-group'
  end

  its(:security_groups) { is_expected.to eq ['sg-aabbccdd', 'sg-ddccbbaa'] }
end

RSpec.describe ElasticLoadBalancing::LoadBalancer.new(
  'test-elb2',
  elb2
) do
  its(:to_s) do
    is_expected.to eq 'ElasticLoadBalancing LoadBalancer: test-elb2'
  end

  it { is_expected.to be_internet_facing }
end
