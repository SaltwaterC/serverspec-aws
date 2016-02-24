# encoding: utf-8

module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The VPC class exposes the EC2::VPC resources
        class VPC < Base
          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing a
          # VPC resource
          # @param vpc_id [String] The ID of the VPC
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if vpcs.nil?
          # @raise [RuntimeError] if vpcs.length == 0
          # @raise [RuntimeError] if vpcs.length > 1
          def initialize(vpc_id, instance = nil)
            check_init_arg 'vpc_id', 'EC2::VPC', vpc_id
            @vpc_id = vpc_id
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            get_vpc vpc_id
          end

          # Returns the string representation of EC2::VPC
          # @return [String]
          def to_s
            "EC2 VPC: #{@vpc_id}"
          end

          # Indicates whether the state is available
          def available?
            @vpc.state == 'available'
          end

          # Indicates whether the VPC is the default VPC
          def default?
            @vpc.is_default
          end

          # Indicates whether the instance_tenancy is default
          def default_tenancy?
            @vpc.instance_tenancy == 'default'
          end

          # The CIDR block for the VPC
          # @return [String]
          def cidr_block
            @vpc.cidr_block
          end

          # The ID of the set of DHCP options you've associated with the VPC
          # (or default if the default options are associated with the VPC)
          # @return [String]
          def dhcp_options_id
            @vpc.dhcp_options_id
          end

          # Any tags assigned to the VPC
          # @return [Array(Hash)]
          def tags
            @vpc.tags
          end
          
          # Get the subnets associated with the VPC
          def subnets
            Subnets.new (Aws::EC2::Vpc.new(@vpc_id, :client => @aws).subnets)
          end

          private

          # @private
          def get_vpc(id)
            vpcs = @aws.describe_vpcs(vpc_ids: [id]).vpcs
            check_length 'vpcs', vpcs
            @vpc = vpcs[0]
          end
        end
      end
    end
  end
end
