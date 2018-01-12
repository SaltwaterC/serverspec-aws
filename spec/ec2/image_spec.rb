ec21 = Aws::EC2::Client.new
# stub Instance
ec21.stub_responses(
  :describe_images,
  images: [
    {
      image_id: 'ami-aabbccdd',
      image_location: '000000000000000000000/my-ami',
      state: 'available',
      owner_id: '000000000000000000000',
      creation_date: '2016-09-29T03:38:31.000Z',
      public: false,
      product_codes: [],
      architecture: 'x86_64',
      image_type: 'machine',
      kernel_id: nil,
      ramdisk_id: nil,
      platform: nil,
      sriov_net_support: 'simple',
      ena_support: nil,
      state_reason: nil,
      image_owner_alias: nil,
      name: 'my-ami',
      description: nil,
      root_device_type: 'ebs',
      root_device_name: '/dev/sda1',
      block_device_mappings: [
        {
          virtual_name: nil,
          device_name: '/dev/sda1',
          ebs: {
            snapshot_id: 'snap-11111111', #=> String
            volume_size: 8, #=> Integer
            delete_on_termination: true, #=> true/false
            # String, one of "standard", "io1", "gp2", "sc1", "st1"
            volume_type: 'gp2',
            iops: nil, #=> Integer
            encrypted: false #=> true/false
          },
          no_device: nil, #=> String
        },
        {
          virtual_name: 'ephemeral0',
          device_name: '/dev/sdb',
          ebs: nil,
          no_device: nil, #=> String
        },
        {
          virtual_name: 'ephemeral1',
          device_name: '/dev/sdc',
          ebs: nil,
          no_device: nil, #=> String
        }
      ],
      virtualization_type: 'hvm', #=> String, one of "hvm", "paravirtual"
      tags: [], #=> Array
      hypervisor: 'xen' #=> String, one of "ovm", "xen"
    }
  ]
)

ec22 = Aws::EC2::Client.new
# stub Instance
ec22.stub_responses(
  :describe_images,
  images: [
    {
      image_id: 'ami-12345678901234567',
      image_location: '000000000000000000000/my-ami2',
      state: 'available',
      owner_id: '000000000000000000000',
      creation_date: '2016-09-29T03:38:31.000Z',
      public: false,
      product_codes: [],
      architecture: 'x86_64',
      image_type: 'machine',
      kernel_id: nil,
      ramdisk_id: nil,
      platform: nil,
      sriov_net_support: 'simple',
      ena_support: nil,
      state_reason: nil,
      image_owner_alias: nil,
      name: 'my-ami2',
      description: nil,
      root_device_type: 'ebs',
      root_device_name: '/dev/sda1',
      block_device_mappings: [
        {
          virtual_name: nil,
          device_name: '/dev/sda1',
          ebs: {
            snapshot_id: 'snap-22222222', #=> String
            volume_size: 8, #=> Integer
            delete_on_termination: true, #=> true/false
            #=> String, one of "standard", "io1", "gp2", "sc1", "st1"
            volume_type: 'gp2',
            iops: nil, #=> Integer
            encrypted: true #=> true/false
          },
          no_device: nil, #=> String
        },
        {
          virtual_name: 'ephemeral0',
          device_name: '/dev/sdb',
          ebs: nil,
          no_device: nil, #=> String
        },
        {
          virtual_name: 'ephemeral1',
          device_name: '/dev/sdc',
          ebs: nil,
          no_device: nil, #=> String
        }
      ],
      virtualization_type: 'hvm', #=> String, one of "hvm", "paravirtual"
      tags: [], #=> Array
      hypervisor: 'xen' #=> String, one of "ovm", "xen"
    }
  ]
)

RSpec.describe EC2::Image.new('ami-aabbccdd', ec21) do
  its(:to_s) { is_expected.to eq 'EC2 Image ID: ami-aabbccdd; Name: my-ami' }
  its(:image_id) { should eq 'ami-aabbccdd' }
  its(:image_name) { should eq 'my-ami' }

  its(:root_volume) do
    root_volume = subject.root_volume
    expect(root_volume.snapshot_id).to eq 'snap-11111111'
    expect(root_volume.device_name).to eq '/dev/sda1'
    expect(root_volume.type).to eq 'ebs'
  end

  its(:root_volume) { should_not be_encrypted }
end

RSpec.describe EC2::Image.new('my-ami2', ec22) do
  its(:image_id) { should eq 'ami-12345678901234567' }
  its(:image_name) { should eq 'my-ami2' }

  its(:to_s) do
    is_expected.to eq 'EC2 Image ID: ami-12345678901234567; Name: my-ami2'
  end

  its(:root_volume) { should be_encrypted }
end
