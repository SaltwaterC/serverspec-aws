module Serverspec
  module Type
    module AWS
      # The RDS module contains the RDS API resources
      module RDS
        # The DBInstance class exposes the RDS::DBInstance resources
        class DBInstance < Base # rubocop:disable ClassLength
          require 'netaddr'

          # AWS SDK for Ruby v2 Aws::RDS::Client wrapper for initializing a
          # DBInstance resource
          # @param dbi_name [String] The name of the DBInstance
          # @param instance [Class] Aws::RDS::Client instance
          # @param ec2 [Class] Aws::EC2::Client ec2
          # @raise [RuntimeError] if dbis.nil?
          # @raise [RuntimeError] if dbis.length == 0
          # @raise [RuntimeError] if dbis.length > 1
          def initialize(dbi_name, instance = nil, ec2 = nil)
            check_init_arg 'dbi_name', 'RDS::DBInstance', dbi_name
            @dbi_name = dbi_name
            @aws = instance.nil? ? Aws::RDS::Client.new : instance
            @ec2 = ec2.nil? ? Aws::EC2::Client.new : ec2
            get_dbi dbi_name
          end

          # Returns the string representation of RDS::DBInstance
          # @return [String]
          def to_s
            "RDS DBInstance: #{@dbi_name}"
          end

          # Indicates whether instance status is available
          def available?
            @dbi.db_instance_status == 'available'
          end

          # Specifies if the DB instance is a Multi-AZ deployment
          def multi_az?
            @dbi.multi_az
          end

          # Indicates that minor version patches are applied automatically
          def auto_minor_version_upgradeable?
            @dbi.auto_minor_version_upgrade
          end

          # Specifies the accessibility options for the DB instance. A value of
          # true specifies an Internet-facing instance with a publicly
          # resolvable DNS name, which resolves to a public IP address. A value
          # of false specifies an internal instance with a DNS name that
          # resolves to a private IP address
          def publicly_accessible?
            @dbi.publicly_accessible
          end

          # Specifies whether the DB instance is encrypted
          def with_encrypted_storage?
            @dbi.storage_encrypted
          end

          # Tests whether the database should allow connections
          # from the given CIDR range. Inspects each of the security groups
          # associated with the instance and associated inbound rules
          # to check for a rule matching the given CIDR range.
          # For external CIDR ranges, it is verified that the database is
          # publicly accessible.
          #
          # Even if this method returns true, it does not necessarily mean that
          # actual connections made to the RDS instance will succeed.
          #
          # Examples that may prevent actual connection are:
          # * NACL entries
          # * Enabled ports
          # * Security Group Egress rules
          def accessible_from?(cidr)
            return false if public_cidr?(cidr) && !publicly_accessible?

            vpc_security_groups.each do |sg|
              security_group = AWS::EC2::SecurityGroup.new(sg, @ec2)
              return true if security_group.accessible_from?(cidr)
            end

            false
          end

          # Contains the name of the compute and memory capacity class of the DB
          # instance
          # @return [String]
          def instance_class
            @dbi.db_instance_class
          end

          # Provides the name of the database engine to be used for this DB
          # instance
          # @return [String]
          def engine
            @dbi.engine
          end

          # Contains the master username for the DB instance
          # @return [String]
          def master_username
            @dbi.master_username
          end

          # The meaning of this parameter differs according to the database
          # engine you use
          # @return [String]
          def database_name
            @dbi.db_name
          end

          # Specifies the connection endpoint DNS address of the DB instance
          # @return [String]
          def endpoint
            @dbi.endpoint.address
          end

          # Specifies the port that the database engine is listening on
          # @return [Integer]
          def listening_port
            @dbi.endpoint.port
          end

          # Specifies the allocated storage size specified in gigabytes
          # @return [Integer]
          def allocated_storage
            @dbi.allocated_storage
          end

          # Specifies the daily time range during which automated backups are
          # created if automated backups are enabled, as determined by the
          # BackupRetentionPeriod
          # @return [String]
          def preferred_backup_window
            @dbi.preferred_backup_window
          end

          # Specifies the number of days for which automatic DB snapshots are
          # retained
          # @return [Integer]
          def backup_retention_period
            @dbi.backup_retention_period
          end

          # Provides List of active DB security group names
          # @return [Array(String)]
          def security_groups
            sgs = []
            @dbi.db_security_groups.each do |sg|
              sgs << sg.db_security_group_name if sg.status == 'active'
            end
            sgs
          end

          # Provides List of VPC security group elements that the DB instance
          # belongs to
          # @return [Array(String)]
          def vpc_security_groups
            vsgs = []
            @dbi.vpc_security_groups.each do |vsg|
              vsgs << vsg.vpc_security_group_id if vsg.status == 'active'
            end
            vsgs
          end

          # Provides the list of DB parameter groups applied to this DB instance
          # @return [Array(Hash)]
          def parameter_groups
            @dbi.db_parameter_groups
          end

          # Specifies the name of the Availability Zone the DB instance is
          # located in
          # @return [String]
          def availability_zone
            @dbi.availability_zone
          end

          # Specifies information on the subnet group associated with the DB
          # instance, including the name, description, and subnets in the subnet
          # group
          # @return [Hash]
          def subnet_group
            @dbi.db_subnet_group
          end

          # Specifies the weekly time range (in UTC) during which system
          # maintenance can occur
          # @return [String]
          def preferred_maintenance_window
            @dbi.preferred_maintenance_window
          end

          # Specifies that changes to the DB instance are pending. This element
          # is only included when changes are pending. Specific changes are
          # identified by subelements
          # @return [Hash]
          def pending_modified_values
            @dbi.pending_modified_values
          end

          # Indicates the database engine version
          # @return [String]
          def engine_version
            @dbi.engine_version
          end

          # Contains the identifier of the source DB instance if this DB
          # instance is a Read Replica
          # @return [String]
          def read_replica_source_db_instance_identifier
            @dbi.read_replica_source_db_instance_identifier
          end

          # Contains one or more identifiers of the Read Replicas associated
          # with this DB instance
          # @return [Array(String)]
          def read_replica_db_instance_identifiers
            @dbi.read_replica_db_instance_identifiers
          end

          # License model information for this DB instance
          # @return [String]
          def license_model
            @dbi.license_model
          end

          # Specifies the Provisioned IOPS (I/O operations per second) value
          # @return [Integer]
          def iops
            @dbi.iops
          end

          # Provides the list of option group memberships for this DB instance
          # @return [Array(Hash)]
          def option_group_memberships
            @dbi.option_group_memberships
          end

          # If present, specifies the name of the character set that this
          # instance is associated with
          # @return [String]
          def character_set_name
            @dbi.character_set_name
          end

          # If present, specifies the name of the secondary Availability Zone
          # for a DB instance with multi-AZ support
          # @return [String]
          def secondary_availability_zone
            @dbi.secondary_availability_zone
          end

          # The status of a Read Replica. If the instance is not a Read Replica,
          # this will be blank
          # @return [Array(Hash)]
          def status_infos
            @dbi.status_infos
          end

          # Specifies the storage type associated with DB instance
          # @return [String]
          def storage_type
            @dbi.storage_type
          end

          # The ARN from the Key Store with which the instance is associated for
          # TDE encryption
          # @return [String]
          def tde_credential_arn
            @dbi.tde_credential_arn
          end

          # If StorageEncrypted is true, the KMS key identifier for the
          # encrypted DB instance
          # @return [String]
          def kms_key_id
            @dbi.kms_key_id
          end

          # If StorageEncrypted is true, the region-unique, immutable identifier
          # for the encrypted DB instance. This identifier is found in AWS
          # CloudTrail log entries whenever the KMS key for the DB instance is
          # accessed
          # @return [String]
          def dbi_resource_id
            @dbi.dbi_resource_id
          end

          # The identifier of the CA certificate for this DB instance
          # @return [String]
          def ca_certificate_identifier
            @dbi.ca_certificate_identifier
          end

          private

          # @private
          def get_dbi(name)
            dbs = @aws.describe_db_instances(
              db_instance_identifier: name
            ).db_instances
            check_length 'database instances', dbs
            @dbi = dbs[0]
          end

          # Is the given CIDR in the public address range
          # @param cidr_s String representation of CIDR range.
          #               e.g. '192.168.0.0/16'
          # @see https://en.wikipedia.org/wiki/IP_address#Private_addresses
          # @private
          def public_cidr?(cidr_s)
            cidr = NetAddr::CIDR.create(cidr_s)
            # CIDR ranges reserved for internal addresses
            [
              '10.0.0.0/8', '172.16.0.0/12', '198.168.0.0/16'
            ].each do |private_cidr|
              if cidr == private_cidr || cidr.is_contained?(private_cidr)
                return false
              end
            end
            true
          end
        end
      end
    end
  end
end
