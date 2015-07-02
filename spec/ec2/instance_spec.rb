# encoding: utf-8

ec21 = Aws::EC2::Client.new
# stub Instance
ec21.stub_responses(:describe_instances, reservations: [
  {
    reservation_id: 'r-aabbccdd',
    instances: [
      {
        instance_id: 'i-aabbccdd',
        image_id: 'ami-aabbccdd',
        state: {
          code: 16,
          name: 'running'
        },
        private_dns_name: 'ip-10-0-0-1.us-east-1.compute.internal',
        public_dns_name: 'ec2-1-2-3-4.compute-1.amazonaws.com',
        key_name: 'test-key',
        instance_type: 't2.micro',
        placement: {
          availability_zone: 'us-east-1a',
          group_name: '',
          tenancy: 'default'
        },
        kernel_id: 'aki-aabbccdd',
        ramdisk_id: 'ari-aabbccdd',
        # this is not consistent, but the testing must be done
        platform: 'Windows',
        monitoring: {
          state: 'enabled'
        },
        subnet_id: 'subnet-aabbccdd',
        vpc_id: 'vpc-aabbccdd',
        private_ip_address: '10.0.0.1',
        public_ip_address: '1.2.3.4',
        architecture: 'x86_64',
        root_device_type: 'ebs',
        root_device_name: '/dev/xvda',
        block_device_mappings: [{
          device_name: '/dev/xvda',
          ebs: {
            volume_id: 'vol-aabbccdd',
            status: 'attached',
            attach_time: Time.new,
            delete_on_termination: true
          }
        }],
        virtualization_type: 'hvm',
        instance_lifecycle: nil,
        tags: [
          {
            key: 'test-key',
            value: 'test-value'
          }
        ],
        security_groups: [
          {
            group_name: 'test-group',
            group_id: 'sg-aabbccdd'
          }
        ],
        source_dest_check: true,
        hypervisor: 'xen',
        network_interfaces: [
          {
            network_interface_id: 'eni-aabbccdd',
            subnet_id: 'subnet-aabbccdd',
            vpc_id: 'vpc-aabbccdd',
            description: 'eni description',
            owner_id: '000000000000000000000',
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
              device_index: 0,
              status: 'attached',
              attach_time: Time.new,
              delete_on_termination: true
            },
            association: nil,
            private_ip_addresses: [
              {
                private_ip_address: '10.0.0.1',
                private_dns_name: nil,
                primary: true,
                association: nil
              }
            ]
          }
        ],
        iam_instance_profile: {
          arn: 'arn:aws:iam::000000000000000000000:instance-profile/'\
            'test-instance-profile',
          id: 'AAAAAAAAAAAAAAAAAAAAA'
        },
        ebs_optimized: true,
        sriov_net_support: 'simple'
      }
    ]
  }
])

ec22 = Aws::EC2::Client.new
ec22.stub_responses(:describe_instances, reservations: [
  {
    reservation_id: 'r-aabbccdd',
    instances: [
      {
        instance_id: 'i-aabbccdd',
        tags: [
          {
            key: 'Name',
            value: 'test-instance'
          }
        ]
      }
    ]
  }
])

RSpec.describe instance1 = EC2::Instance.new('i-aabbccdd', ec21) do
  its(:to_s) { is_expected.to eq 'EC2 Instance ID: i-aabbccdd' }

  it { is_expected.to be_running }
  it { is_expected.to be_monitoring_enabled }
  it { is_expected.to be_on_windows }
  it { is_expected.to be_source_dest_checked }
  it { is_expected.to be_ebs_optimized }
  it { is_expected.to be_enhanced_networked }

  its(:image_id) { is_expected.to eq 'ami-aabbccdd' }
  its(:private_dns_name) do
    is_expected.to eq 'ip-10-0-0-1.us-east-1.compute.internal'
  end
  its(:public_dns_name) do
    is_expected.to eq 'ec2-1-2-3-4.compute-1.amazonaws.com'
  end
  its(:key_name) { is_expected.to eq 'test-key' }
  its(:instance_type) { is_expected.to eq 't2.micro' }

  its(:placement) do
    placement = instance1.placement
    expect(placement.availability_zone).to eq 'us-east-1a'
    expect(placement.group_name).to eq ''
    expect(placement.tenancy).to eq 'default'
  end

  its(:kernel_id) { is_expected.to eq 'aki-aabbccdd' }
  its(:ramdisk_id) { is_expected.to eq 'ari-aabbccdd' }
  its(:subnet_id) { is_expected.to eq 'subnet-aabbccdd' }
  its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }
  its(:private_ip_address) { is_expected.to eq '10.0.0.1' }
  its(:public_ip_address) { is_expected.to eq '1.2.3.4' }
  its(:architecture) { is_expected.to eq 'x86_64' }
  its(:root_device_type) { is_expected.to eq 'ebs' }
  its(:root_device_name) { is_expected.to eq '/dev/xvda' }

  its(:block_device_mappings) do
    dev = instance1.block_device_mappings[0]
    expect(dev.device_name).to eq '/dev/xvda'
    expect(dev.ebs.volume_id).to eq 'vol-aabbccdd'
    expect(dev.ebs.status).to eq 'attached'
    expect(dev.ebs.delete_on_termination).to eq true
  end

  its(:virtualization_type) { is_expected.to eq 'hvm' }
  its(:instance_lifecycle) { is_expected.to eq nil }

  its(:tags) do
    tag = instance1.tags[0]
    expect(tag.key).to eq 'test-key'
    expect(tag.value).to eq 'test-value'
  end

  its(:security_groups) do
    sg = instance1.security_groups[0]
    expect(sg.group_name).to eq 'test-group'
    expect(sg.group_id).to eq 'sg-aabbccdd'
  end

  its(:hypervisor) { is_expected.to eq 'xen' }

  its(:network_interfaces) do
    eni = instance1.network_interfaces[0]
    expect(eni.network_interface_id).to eq 'eni-aabbccdd'
    expect(eni.subnet_id).to eq 'subnet-aabbccdd'
    expect(eni.vpc_id).to eq 'vpc-aabbccdd'
    expect(eni.description).to eq 'eni description'
    expect(eni.owner_id).to eq '000000000000000000000'
    expect(eni.status).to eq 'in-use'
    expect(eni.mac_address).to eq 'aa:bb:cc:dd:ee:ff'
    expect(eni.private_ip_address).to eq '10.0.0.1'
    expect(eni.private_dns_name).to eq nil
    expect(eni.source_dest_check).to eq true
    expect(eni.attachment.attachment_id).to eq 'eni-attach-aabbccdd'
    expect(eni.attachment.device_index).to eq 0
    expect(eni.attachment.status).to eq 'attached'
    expect(eni.attachment.delete_on_termination).to eq true
    expect(eni.association).to eq nil

    sg = eni.groups[0]
    expect(sg.group_name).to eq 'test-group'
    expect(sg.group_id).to eq 'sg-aabbccdd'

    pi = eni.private_ip_addresses[0]
    expect(pi.private_ip_address).to eq '10.0.0.1'
    expect(pi.private_dns_name).to eq nil
    expect(pi.primary).to eq true
    expect(pi.association).to eq nil
  end

  its(:iam_instance_profile) do
    prof = instance1.iam_instance_profile
    expect(prof.arn).to eq 'arn:aws:iam::000000000000000000000:'\
      'instance-profile/test-instance-profile'
    expect(prof.id).to eq 'AAAAAAAAAAAAAAAAAAAAA'
  end
end

RSpec.describe EC2::Instance.new('test-instance', ec22) do
  its(:to_s) do
    is_expected.to eq 'EC2 Instance ID: i-aabbccdd; Name: test-instance'
  end
end
