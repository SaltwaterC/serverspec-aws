module Serverspec
  module Type
    module AWS
      # The Redshift module contains the Redshift API resources
      module Redshift
        # The Cluster class exposes the Redshift::Cluster resources
        class Cluster < Base # rubocop:disable ClassLength
          # AWS SDK for Ruby v2 Aws::RDS::Client wrapper for initializing a
          # Cluster resource
          # @param cluster_id [String] The ID of the Cluster
          # @param instance [Class] Aws::Redshift::Client instance
          # @raise [RuntimeError] if clusters.nil?
          # @raise [RuntimeError] if clusters.length == 0
          # @raise [RuntimeError] if clusters.length > 1
          def initialize(cluster_id, instance = nil)
            check_init_arg 'cluster_id', 'Redshift::Cluster', cluster_id
            @cluster_id = cluster_id
            @aws = instance.nil? ? Aws::Redshift::Client.new : instance
            get_cluster cluster_id
          end

          # Returns the string representation of Redshift::Cluster
          # @return [String]
          def to_s
            "Redshift Cluster: #{@cluster_id}"
          end

          # Indicates whether cluster_status is available
          def available?
            @cluster.cluster_status == 'available'
          end

          # If true, major version upgrades will be applied automatically to the
          # cluster during the maintenance window
          def version_upgradeable?
            @cluster.allow_version_upgrade
          end

          # If true, the cluster can be accessed from a public network
          def publicly_accessible?
            @cluster.publicly_accessible
          end

          # If true, data in the cluster is encrypted at rest
          def encrypted?
            @cluster.encrypted
          end

          # The node type for the nodes in the cluster
          # @return [String]
          def node_type
            @cluster.node_type
          end

          # The status of a modify operation, if any, initiated for the cluster
          # @return [String]
          def modify_status
            @cluster.modify_status
          end

          # The master user name for the cluster. This name is used to connect
          # to the database that is specified in DBName
          # @return [String]
          def master_username
            @cluster.master_username
          end

          # The name of the initial database that was created when the cluster
          # was created. This same name is returned for the life of the cluster.
          # If an initial database was not specified, a database named "dev" was
          # created by default
          # @return [String]
          def database_name
            @cluster.db_name
          end

          # The connection endpoint DNS address of the Cluster
          # @return [String]
          def endpoint
            @cluster.endpoint.address
          end

          # The port that the database engine is listening on
          # @return [Integer]
          def listening_port
            @cluster.endpoint.port
          end

          # The number of days that automatic cluster snapshots are retained
          # @return [Integer]
          def automated_snapshot_retention_period
            @cluster.automated_snapshot_retention_period
          end

          # A list of active cluster security groups
          # @return [Array(String)]
          def security_groups
            sgs = []
            @cluster.cluster_security_groups.each do |sg|
              sgs << sg.cluster_security_group_name if sg.status == 'active'
            end
            sgs
          end

          # A list of active VPC security groups
          # @return [Array(String)]
          def vpc_security_groups
            vsgs = []
            @cluster.vpc_security_groups.each do |vsg|
              vsgs << vsg.vpc_security_group_id if vsg.status == 'active'
            end
            vsgs
          end

          # The list of cluster parameter groups
          # @return [Array(String)]
          def parameter_groups
            cpgs = []
            @cluster.cluster_parameter_groups.each do |cpg|
              cpgs << cpg.parameter_group_name
            end
            cpgs
          end

          # The name of the subnet group that is associated with the cluster.
          # This parameter is valid only when the cluster is in a VPC
          # @return [String]
          def subnet_group
            @cluster.cluster_subnet_group_name
          end

          # The identifier of the VPC the cluster is in, if the cluster is in a
          # VPC
          # @return [String]
          def vpc_id
            @cluster.vpc_id
          end

          # The name of the Availability Zone in which the cluster is located
          # @return [String]
          def availability_zone
            @cluster.availability_zone
          end

          # The weekly time range (in UTC) during which system maintenance can
          # occur
          # @return [String]
          def preferred_maintenance_window
            @cluster.preferred_maintenance_window
          end

          # If present, changes to the cluster are pending. Specific pending
          # changes are identified by subelements
          # @return [Hash]
          def pending_modified_values
            @cluster.pending_modified_values
          end

          # The version ID of the Amazon Redshift engine that is running on the
          # cluster
          # @return [String]
          def version
            @cluster.cluster_version
          end

          # The number of compute nodes in the cluster
          # @return [Integer]
          def number_of_nodes
            @cluster.number_of_nodes
          end

          # Describes the status of a cluster restore action. Returns null if
          # the cluster was not created by restoring a snapshot
          # @return [Hash]
          def restore_status
            @cluster.restore_status
          end

          # Reports whether the Amazon Redshift cluster has finished applying
          # any HSM settings changes specified in a modify cluster command
          # @return [Hash]
          def hsm_status
            @cluster.hsm_status
          end

          # Returns the destination region and retention period that are
          # configured for cross-region snapshot copy
          # @return [Hash]
          def snapshot_copy_status
            @cluster.cluster_snapshot_copy_status
          end

          # The public key for the cluster
          # @return [String]
          def public_key
            @cluster.cluster_public_key
          end

          # The nodes in a cluster
          # @return [Array(Hash)]
          def nodes
            @cluster.cluster_nodes
          end

          # Describes the status of the elastic IP address
          # @return [Hash]
          def elastic_ip_status
            @cluster.elastic_ip_status
          end

          # The specific revision number of the database in the cluster
          # @return [String]
          def revision_number
            @cluster.cluster_revision_number
          end

          # The list of tags for the cluster
          # @return [Array(Hash)]
          def tags
            @cluster.tags
          end

          # The AWS Key Management Service key ID of the encryption key used to
          # encrypt data in the cluster
          # @return [String]
          def kms_key_id
            @cluster.kms_key_id
          end

          private

          # @private
          def get_cluster(id)
            clstrs = @aws.describe_clusters(cluster_identifier: id).clusters
            check_length 'clusters', clstrs
            @cluster = clstrs[0]
          end
        end
      end
    end
  end
end
