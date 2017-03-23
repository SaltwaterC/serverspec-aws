module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The SecurityGroup class exposes the EC2::SecurityGroup resources
        class SecurityGroup < Base
          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing a
          # SecurityGroup resource
          # @param sg_id [String] The ID of the SecurityGroup
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if sgs.nil?
          # @raise [RuntimeError] if sgs.length == 0
          # @raise [RuntimeError] if sgs.length > 1
          def initialize(sg_id, instance = nil)
            check_init_arg 'sg_id', 'EC2::SecurityGroup', sg_id
            @sg_id = sg_id
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            get_security_group sg_id
          end

          # Returns the string representation of EC2::SecurityGroup
          # @return [String]
          def to_s
            "EC2 SecurityGroup: #{@sg_id}"
          end

          # The AWS account ID of the owner of the security group
          # @return [String]
          def owner_id
            @sg.owner_id
          end

          # The name of the security group
          # @return [String]
          def group_name
            @sg.group_name
          end

          # A description of the security group
          # @return [String]
          def description
            @sg.description
          end

          # One or more inbound rules associated with the security group
          # @return [Array(Hash)]
          def ingress_permissions
            @sg.ip_permissions
          end

          # [EC2-VPC] One or more outbound rules associated with the security
          # group
          # @return [Array(Hash)]
          def egress_permissions
            @sg.ip_permissions_egress
          end

          # [EC2-VPC] The ID of the VPC for the security group
          # @return [String]
          def vpc_id
            @sg.vpc_id
          end

          # Any tags assigned to the security group
          # @return [Array(Hash)]
          def tags
            @sg.tags
          end

          private

          # @private
          def get_security_group(id)
            sgs = @aws.describe_security_groups(group_ids: [id]).security_groups
            check_length 'security groups', sgs
            @sg = sgs[0]
          end
        end
      end
    end
  end
end
