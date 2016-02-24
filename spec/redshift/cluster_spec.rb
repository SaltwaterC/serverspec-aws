# encoding: utf-8

rs = Aws::Redshift::Client.new
rs.stub_responses(
  :describe_clusters,
  clusters: [
    {
      cluster_status: 'available',
      allow_version_upgrade: true,
      publicly_accessible: true,
      encrypted: true,
      node_type: 'dw2.large',
      modify_status: nil,
      master_username: 'test-user',
      db_name: 'test-database',
      endpoint: {
        address: 'test-cluster.aaaaaaaaaaaa.us-east-1.amazonaws.com',
        port: 5439
      },
      automated_snapshot_retention_period: 7,
      cluster_security_groups: [],
      vpc_security_groups: [
        {
          vpc_security_group_id: 'sg-aabbccdd',
          status: 'active'
        },
        {
          vpc_security_group_id: 'sg-ddccbbaa',
          status: 'active'
        }
      ],
      cluster_parameter_groups: [
        {
          parameter_group_name: 'test-parameter-group'
        }
      ],
      cluster_subnet_group_name: 'test-subnet-group',
      vpc_id: 'vpc-aabbccdd',
      availability_zone: 'us-east-1a',
      preferred_maintenance_window: 'wed:23:30-thu:00:00',
      pending_modified_values: {
        master_user_password: nil,
        node_type: nil,
        number_of_nodes: nil,
        cluster_type: nil,
        cluster_version: nil,
        automated_snapshot_retention_period: nil,
        cluster_identifier: nil
      },
      cluster_version: '1.0',
      number_of_nodes: 3,
      restore_status: nil,
      hsm_status: nil,
      cluster_snapshot_copy_status: nil,
      cluster_public_key: 'ssh-rsa AAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb '\
        'Amazon-Redshift\n',
      cluster_nodes: [
        {
          node_role: 'SHARED',
          private_ip_address: '10.0.0.10',
          public_ip_address: '55.55.55.55'
        }
      ],
      cluster_revision_number: '934',
      tags: [
        {
          key: 'Name',
          value: 'test-cluster'
        }
      ],
      kms_key_id: nil
    }
  ]
)

RSpec.describe cluster = Redshift::Cluster.new('test-cluster', rs) do
  its(:to_s) { is_expected.to eq 'Redshift Cluster: test-cluster' }

  it { is_expected.to be_available }
  it { is_expected.to be_version_upgradeable }
  it { is_expected.to be_publicly_accessible }
  it { is_expected.to be_encrypted }

  its(:node_type) { is_expected.to eq 'dw2.large' }
  its(:modify_status) { is_expected.to eq nil }
  its(:master_username) { is_expected.to eq 'test-user' }
  its(:database_name) { is_expected.to eq 'test-database' }

  its(:endpoint) do
    is_expected.to eq 'test-cluster.aaaaaaaaaaaa.us-east-1.amazonaws.com'
  end

  its(:listening_port) { is_expected.to eq 5439 }
  its(:automated_snapshot_retention_period) { is_expected.to eq 7 }
  its(:security_groups) { is_expected.to eq [] }
  its(:vpc_security_groups) { is_expected.to eq ['sg-aabbccdd', 'sg-ddccbbaa'] }
  its(:parameter_groups) { is_expected.to eq ['test-parameter-group'] }
  its(:subnet_group) { is_expected.to eq 'test-subnet-group' }
  its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }
  its(:availability_zone) { is_expected.to eq 'us-east-1a' }
  its(:preferred_maintenance_window) { is_expected.to eq 'wed:23:30-thu:00:00' }

  its(:pending_modified_values) do
    pmv = cluster.pending_modified_values
    expect(pmv.master_user_password).to eq nil
    expect(pmv.node_type).to eq nil
    expect(pmv.number_of_nodes).to eq nil
    expect(pmv.cluster_type).to eq nil
    expect(pmv.cluster_version).to eq nil
    expect(pmv.automated_snapshot_retention_period).to eq nil
    expect(pmv.cluster_identifier).to eq nil
  end

  its(:version) { is_expected.to eq '1.0' }
  its(:number_of_nodes) { is_expected.to eq 3 }
  its(:restore_status) { is_expected.to eq nil }
  its(:hsm_status) { is_expected.to eq nil }
  its(:snapshot_copy_status) { is_expected.to eq nil }

  its(:public_key) do
    is_expected.to eq 'ssh-rsa AAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'\
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb Amazon-Redshift\n'
  end

  its(:nodes) do
    node = cluster.nodes[0]
    expect(node.node_role).to eq 'SHARED'
    expect(node.private_ip_address).to eq '10.0.0.10'
    expect(node.public_ip_address).to eq '55.55.55.55'
  end

  its(:elastic_ip_status) { is_expected.to eq nil }
  its(:revision_number) { is_expected.to eq '934' }

  its(:tags) do
    tag = cluster.tags[0]
    expect(tag.key).to eq 'Name'
    expect(tag.value).to eq 'test-cluster'
  end

  its(:kms_key_id) { is_expected.to eq nil }
end
