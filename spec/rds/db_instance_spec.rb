rds = Aws::RDS::Client.new
ec2 = Aws::EC2::Client.new

db_stub_response = {
  db_instance_class: 'db.t2.micro',
  engine: 'postgres',
  db_instance_status: 'available',
  master_username: 'test-username',
  db_name: 'test-database',
  endpoint: {
    address: 'test-rds-db.aaaaaaaaaaaa.us-east-1.rds.amazonaws.com'
  },
  allocated_storage: 5,
  preferred_backup_window: '23:00-00:00',
  backup_retention_period: 1,
  db_security_groups: [],
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
  db_parameter_groups: [
    {
      db_parameter_group_name: 'default.postgres9.3',
      parameter_apply_status: 'in-sync'
    }
  ],
  availability_zone: 'us-east-1a',
  db_subnet_group: {
    db_subnet_group_name: 'test-subnet-group',
    db_subnet_group_description: 'test-subnet-group desc',
    vpc_id: 'vpc-aabbccdd',
    subnet_group_status: 'Complete',
    subnets: [
      {
        subnet_identifier: 'subnet-aabbccdd',
        subnet_availability_zone: {
          name: 'us-east-1a'
        },
        subnet_status: 'Active'
      },
      {
        subnet_identifier: 'subnet-ddccbbcc',
        subnet_availability_zone: {
          name: 'us-east-1b'
        },
        subnet_status: 'Active'
      }
    ]
  },
  preferred_maintenance_window: 'sun:00:00-sun:01:00',
  pending_modified_values: {
    db_instance_class: nil,
    allocated_storage: nil,
    master_user_password: nil,
    port: nil,
    backup_retention_period: nil,
    multi_az: nil,
    engine_version: nil,
    iops: nil,
    db_instance_identifier: nil,
    storage_type: nil,
    ca_certificate_identifier: nil
  },
  multi_az: true,
  engine_version: '9.3.3',
  auto_minor_version_upgrade: true,
  read_replica_source_db_instance_identifier: nil,
  read_replica_db_instance_identifiers: [],
  license_model: 'postgresql-license',
  iops: 100,
  option_group_memberships: [
    {
      option_group_name: 'default:postgres-9-3',
      status: 'in-sync'
    }
  ],
  character_set_name: nil,
  secondary_availability_zone: 'us-east-1b',
  publicly_accessible: true,
  status_infos: [],
  storage_type: 'gp2',
  tde_credential_arn: nil,
  storage_encrypted: true,
  kms_key_id: nil,
  dbi_resource_id: 'db-AAAAAAAAAAAAAAAAAAAAAAAAAA',
  ca_certificate_identifier: 'rds-ca-2015'
}

# rubocop:disable Metrics/MethodLength
def security_group(id, overrides = {})
  template = {
    owner_id: '000000000000000000000',
    group_name: 'test-group',
    group_id: id,
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

  stub_response(template, overrides)
end
# rubocop:enable

def rule(cidr)
  {
    ip_protocol: 'tcp',
    from_port: 3306,
    to_port: 3306,
    user_id_group_pairs: [],
    ip_ranges: [
      { cidr_ip: cidr }
    ],
    prefix_list_ids: []
  }
end

def stub_security_groups(ec2, sg_aabbccdd, sg_ddccbbaa)
  ec2.stub_responses(
    :describe_security_groups,
    [
      { security_groups: [sg_aabbccdd] },
      { security_groups: [sg_ddccbbaa] }
    ]
  )
end

rds.stub_responses(
  :describe_db_instances,
  db_instances: [
    db_stub_response
  ]
)

RSpec.describe db_inst = RDS::DBInstance.new('test-rds-db', rds) do
  its(:to_s) { is_expected.to eq 'RDS DBInstance: test-rds-db' }

  it { is_expected.to be_available }
  it { is_expected.to be_multi_az }
  it { is_expected.to be_auto_minor_version_upgradeable }
  it { is_expected.to be_publicly_accessible }
  it { is_expected.to be_with_encrypted_storage }

  its(:instance_class) { is_expected.to eq 'db.t2.micro' }
  its(:engine) { is_expected.to eq 'postgres' }
  its(:master_username) { is_expected.to eq 'test-username' }
  its(:database_name) { is_expected.to eq 'test-database' }

  its(:endpoint) do
    is_expected.to eq 'test-rds-db.aaaaaaaaaaaa.us-east-1.rds.amazonaws.com'
  end

  its(:allocated_storage) { is_expected.to eq 5 }
  its(:preferred_backup_window) { is_expected.to eq '23:00-00:00' }
  its(:backup_retention_period) { is_expected.to eq 1 }
  its(:security_groups) { is_expected.to eq [] }
  its(:vpc_security_groups) { is_expected.to eq ['sg-aabbccdd', 'sg-ddccbbaa'] }

  its(:parameter_groups) do
    pg = db_inst.parameter_groups[0]
    expect(pg.db_parameter_group_name).to eq 'default.postgres9.3'
    expect(pg.parameter_apply_status).to eq 'in-sync'
  end

  its(:availability_zone) { is_expected.to eq 'us-east-1a' }

  its(:subnet_group) do
    group = db_inst.subnet_group
    expect(group.db_subnet_group_name).to eq 'test-subnet-group'
    expect(group.db_subnet_group_description).to eq 'test-subnet-group desc'
    expect(group.vpc_id).to eq 'vpc-aabbccdd'
    expect(group.subnet_group_status).to eq 'Complete'

    subnet0 = group.subnets[0]
    expect(subnet0.subnet_identifier).to eq 'subnet-aabbccdd'
    expect(subnet0.subnet_availability_zone.name).to eq 'us-east-1a'
    expect(subnet0.subnet_status).to eq 'Active'

    subnet1 = group.subnets[1]
    expect(subnet1.subnet_identifier).to eq 'subnet-ddccbbcc'
    expect(subnet1.subnet_availability_zone.name).to eq 'us-east-1b'
    expect(subnet1.subnet_status).to eq 'Active'
  end

  its(:preferred_maintenance_window) { is_expected.to eq 'sun:00:00-sun:01:00' }

  its(:pending_modified_values) do
    pmv = db_inst.pending_modified_values
    expect(pmv.db_instance_class).to eq nil
    expect(pmv.allocated_storage).to eq nil
    expect(pmv.master_user_password).to eq nil
    expect(pmv.port).to eq nil
    expect(pmv.backup_retention_period).to eq nil
    expect(pmv.multi_az).to eq nil
    expect(pmv.engine_version).to eq nil
    expect(pmv.iops).to eq nil
    expect(pmv.db_instance_identifier).to eq nil
    expect(pmv.storage_type).to eq nil
    expect(pmv.ca_certificate_identifier).to eq nil
  end

  its(:read_replica_source_db_instance_identifier) { is_expected.to eq nil }
  its(:read_replica_db_instance_identifiers) { is_expected.to eq [] }
  its(:engine_version) { is_expected.to eq '9.3.3' }
  its(:license_model) { is_expected.to eq 'postgresql-license' }
  its(:iops) { is_expected.to eq 100 }

  its(:option_group_memberships) do
    ogm = db_inst.option_group_memberships[0]
    expect(ogm.option_group_name).to eq 'default:postgres-9-3'
    expect(ogm.status).to eq 'in-sync'
  end

  its(:character_set_name) { is_expected.to eq nil }
  its(:secondary_availability_zone) { is_expected.to eq 'us-east-1b' }
  its(:status_infos) { is_expected.to eq [] }
  its(:storage_type) { is_expected.to eq 'gp2' }
  its(:tde_credential_arn) { is_expected.to eq nil }
  its(:kms_key_id) { is_expected.to eq nil }
  its(:dbi_resource_id) { is_expected.to eq 'db-AAAAAAAAAAAAAAAAAAAAAAAAAA' }
  its(:ca_certificate_identifier) { is_expected.to eq 'rds-ca-2015' }
end

RSpec.describe 'DBInstance#accessible_from?' do
  context 'The database is publicly accessible' do
    before(:each) do
      db_stub_response[:publicly_accessible] = true

      rds.stub_responses(
        :describe_db_instances,
        db_instances: [
          db_stub_response
        ]
      )
    end

    context 'Security Group Rule allows ingress from anywhere' do
      before(:each) do
        stub_security_groups(
          ec2,
          security_group('sg-aabbccdd', ip_permissions: [rule('0.0.0.0/0')]),
          security_group('sg-ddccbbaa')
        )

        # Cannot use this as part of a describe statement,
        # because stubbing ec2 multiple times
        db_inst = RDS::DBInstance.new('test-rds-db', rds, ec2)
      end

      it 'should be accessible from anywhere' do
        expect(db_inst).to be_accessible_from('0.0.0.0/0')
      end
    end
  end

  context 'The database is not publicly accessible' do
    before(:each) do
      db_stub_response[:publicly_accessible] = false
      rds.stub_responses(
        :describe_db_instances,
        db_instances: [
          db_stub_response
        ]
      )

      db_inst = RDS::DBInstance.new('test-rds-db', rds, ec2)
    end

    context 'Security Group Rule allows ingress from public CIDR' do
      before(:each) do
        stub_security_groups(
          ec2,
          security_group('sg-aabbccdd', ip_permissions: [rule('52.1.0.0/16')]),
          security_group('sg-ddccbbaa')
        )
      end

      it 'should be accessible' do
        expect(db_inst).not_to be_accessible_from('52.1.0.0/16')
      end
    end

    context 'Security Groups Rule allows ingress from private CIDR' do
      before(:each) do
        stub_security_groups(
          ec2,
          security_group('sg-aabbccdd', ip_permissions: [rule('10.0.0.0/8')]),
          security_group('sg-ddccbbaa')
        )
      end

      it 'should be accessible from the entire CIDR range' do
        expect(db_inst).to be_accessible_from('10.0.0.0/8')
      end

      it 'should be accessible from a subset of the CIDR range' do
        expect(db_inst).to be_accessible_from('10.1.1.0/24')
      end
    end
  end
end
