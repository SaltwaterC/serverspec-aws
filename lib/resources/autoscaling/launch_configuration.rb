# encoding: utf-8

module Serverspec
  module Type
    module AWS
      # The AutoScaling module contains the AutoScaling API resources
      module AutoScaling
        # The LaunchConfiguration class exposes the
        # AutoScaling::LaunchConfiguration resources
        class LaunchConfiguration < Base
          # AWS SDK for Ruby v2 Aws::AutoScaling::Client wrapper for
          # initializing a LaunchConfiguration resource
          # @param config_name [String] The name of the LaunchConfiguration
          # @param instance [Class] Aws::AutoScaling::Client instance
          # @raise [RuntimeError] if config_name.nil?
          # @raise [RuntimeError] if configs.length == 0
          # @raise [RuntimeError] if configs.length > 1
          def initialize(config_name, instance = nil)
            check_init_arg(
              'config_name',
              'AutoScaling::LaunchConfiguration',
              config_name
            )
            @config_name = config_name
            @aws = instance.nil? ? Aws::AutoScaling::Client.new : instance
            get_config config_name
          end

          # Returns the String representation of
          # AutoScaling::LaunchConfiguration
          def to_s
            "AutoScaling LaunchConfiguration: #{@config_name}"
          end

          # Check if the Instance monitoring is enabled
          def instance_monitored?
            @config.instance_monitoring.enabled
          end

          # Check if the Instance is optimized for EBS I/O
          def ebs_optimized?
            @config.ebs_optimized
          end

          # Check whether the EC2 Instances are associated with a public IP
          # address
          def with_public_ip_address?
            @config.associate_public_ip_address
          end

          # Check if the Instance tenancy is default
          def default_tenancy?
            @config.placement_tenancy == 'default'
          end

          # The ID of the AMI
          # @return [String]
          def image_id
            @config.image_id
          end

          # The name of the key pair
          # @return [String]
          def key_name
            @config.key_name
          end

          # The SecurityGroups to associate with the EC2 Instances
          # @return [Array(String)]
          def security_groups
            @config.security_groups
          end

          # The ID of a ClassicLink-enabled VPC to link your EC2-Classic
          # Instances to
          # @return [String]
          def classic_link_vpc_id
            @config.classic_link_vpc_id
          end

          # The IDs of one or more SecurityGroups for the VPC specified in
          # ClassicLinkVPCId
          # @return [Array(String)]
          def classic_link_vpc_security_groups
            @config.classic_link_vpc_security_groups
          end

          # The user data available to the EC2 Instances
          # @return [String]
          def user_data
            @config.user_data
          end

          # The Instance type for the EC2 Instances
          # @return [String]
          def instance_type
            @config.instance_type
          end

          # The ID of the kernel associated with the AMI
          # @return [String]
          def kernel_id
            @config.kernel_id
          end

          # The ID of the RAM disk associated with the AMI
          # @return [String]
          def ramdisk_id
            @config.ramdisk_id
          end

          # A block device mapping that specifies how block devices are exposed
          # to the Instance. See
          # {http://amzn.to/1Q6ohM1 AutoScaling#describe_launch_configurations}
          # @return [Array(Hash)]
          def block_device_mappings
            @config.block_device_mappings
          end

          # The name or ARN of the Instance profile associated with the IAM role
          # for the Instance
          # @return [String]
          def iam_instance_profile
            @config.iam_instance_profile
          end

          private

          # @private
          def get_config(name)
            cfgs = @aws.describe_launch_configurations(
              launch_configuration_names: [name]
            ).launch_configurations
            check_length 'launch configurations', cfgs
            @config = cfgs[0]
          end
        end
      end
    end
  end
end
