module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The Instance class exposes the EC2::Instance resources
        class Instance < Base # rubocop:disable ClassLength
          # The ID of the Instance
          attr_reader :instance_id
          # The Name tag of the Instance (if available)
          attr_reader :instance_name

          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing an
          # Instance resource
          # @param instance_id_name [String] The ID or Name tag of the Instance
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if instance_id_name.nil?
          # @raise [RuntimeError] if instance_id_name.length == 0
          # @raise [RuntimeError] if instance_id_name.length > 1
          def initialize(instance_id_name, instance = nil)
            check_init_arg 'instance_id_name', 'EC2::instance', instance_id_name
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            if instance_id_name.match(/^i-[A-Fa-f0-9]{8}$/).nil?
              @instance_name = instance_id_name
              get_instance_by_name instance_id_name
            else
              @instance_id = instance_id_name
              get_instance_by_id instance_id_name
            end
          end

          # Returns the string representation of EC2::Instance
          # @return [String]
          def to_s
            return "EC2 Instance ID: #{@instance_id}" if @instance_name.nil?
            "EC2 Instance ID: #{@instance_id}; Name: #{@instance_name}"
          end

          # Returns true if the Instance state is 'running'
          def running?
            @instance.state.name == 'running'
          end

          # Indicates whether the monitoring is enabled for the Instance
          def monitoring_enabled?
            @instance.monitoring.state == 'enabled'
          end

          # Returns true if the platform is Windows
          def on_windows?
            @instance.platform == 'Windows'
          end

          # Specifies whether the Instance launched in a VPC is able to perform
          # NAT. The value must be false for the Instance to perform NAT
          def source_dest_checked?
            @instance.source_dest_check
          end

          # Specifies whether the Instance is optimized for EBS I/O
          def ebs_optimized?
            @instance.ebs_optimized
          end

          # Specifies whether enhanced networking is enabled
          def enhanced_networked?
            @instance.sriov_net_support == 'simple'
          end

          # The ID of the AMI used to launch the Instance
          # @return [String]
          def image_id
            @instance.image_id
          end

          # The private DNS name assigned to the Instance
          # @return [String]
          def private_dns_name
            @instance.private_dns_name
          end

          # The public DNS name assigned to the Instance
          # @return [String]
          def public_dns_name
            @instance.public_dns_name
          end

          # The name of the key pair
          # @return [String]
          def key_name
            @instance.key_name
          end

          # The Instance type
          # @return [String]
          def instance_type
            @instance.instance_type
          end

          # The location where the Instance launched. Indicates the availability
          # zone, the placement group, and the Instance tenancy
          # @return [Hash]
          def placement
            @instance.placement
          end

          # The kernel associtated to this Instance
          # @return [String]
          def kernel_id
            @instance.kernel_id
          end

          # The RAM disk associtated to this Instance
          # @return [String]
          def ramdisk_id
            @instance.ramdisk_id
          end

          # The ID of the subnet in which the Instance is running
          # @return [String]
          def subnet_id
            @instance.subnet_id
          end

          # The ID of the VPC in which the Instance is running
          # @return [String]
          def vpc_id
            @instance.vpc_id
          end

          # The private IP address assigned to the Instance
          # @return [String]
          def private_ip_address
            @instance.private_ip_address
          end

          # The public IP address assigned to the Instance
          # @return [String]
          def public_ip_address
            @instance.public_ip_address
          end

          # The architecture of the image
          # @return [String]
          def architecture
            @instance.architecture
          end

          # The root device type used by the AMI. It can be an EBS volume or
          # Instance store
          # @return [String]
          def root_device_type
            @instance.root_device_type
          end

          # The root device name (eg: /dev/sda1, /dev/xvda1)
          # @return [String]
          def root_device_name
            @instance.root_device_name
          end

          # Any block device mappings for the Instance
          # @return [Array(Hash)]
          def block_device_mappings
            @instance.block_device_mappings
          end

          # The virtualization type of the Instance, whether is HVM or PV
          # @return [String]
          def virtualization_type
            @instance.virtualization_type
          end

          # Indicates whether this is a spot Instance
          # @return [String]
          def instance_lifecycle
            @instance.instance_lifecycle
          end

          # Any tags assigned to the Instance
          # @return [Array(Hash)]
          def tags
            @instance.tags
          end

          # One or more SecurityGroups for the Instance
          # @return [Array(Hash)]
          def security_groups
            @instance.security_groups
          end

          # The hypervisor type of the Instance
          # @return [String]
          def hypervisor
            @instance.hypervisor
          end

          # One or more NetworkInterfaces for the Instance
          # @return [Array(Hash)]
          def network_interfaces
            @instance.network_interfaces
          end

          # The IAM Instance profile associtated with the Instance
          # @return [Hash]
          def iam_instance_profile
            @instance.iam_instance_profile
          end

          private

          # @private
          def get_instance_by_id(id)
            res = @aws.describe_instances(instance_ids: [id]).reservations
            check_res 'id', res
            @instance = res[0].instances[0]
            @instance.tags.each do |tag|
              @instance_name = tag.value if tag.key == 'Name'
            end
          end

          # @private
          def get_instance_by_name(name)
            res = @aws.describe_instances(
              filters: [
                { name: 'tag-key', values: ['Name'] },
                { name: 'tag-value', values: [name] },
                { name: 'instance-state-name', values: ['running'] }
              ]
            ).reservations
            check_res 'name', res
            @instance = res[0].instances[0]
            @instance_id = @instance.instance_id
          end

          # @private
          def check_res(type, res)
            check_length 'reservations', res
            check_length "instances by #{type}", res[0].instances
          end
        end
      end
    end
  end
end
