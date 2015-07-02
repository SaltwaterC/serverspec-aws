# encoding: utf-8

module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The Subnet class exposes the EC2::Subnet resources
        class Subnet < Base
          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing a
          # Subnet resource
          # @param subnet_id [String] The ID of the Subnet
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if subnets.nil?
          # @raise [RuntimeError] if subnets.length == 0
          # @raise [RuntimeError] if subnets.length > 1
          def initialize(subnet_id, instance = nil)
            check_init_arg 'subnet_id', 'EC2::Subnet', subnet_id
            @subnet_id = subnet_id
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            get_subnet subnet_id
          end

          # Returns the string representation of EC2::Subnet
          # @return [String]
          def to_s
            "EC2 Subnet: #{@subnet_id}"
          end

          # Indicates whether the state is available
          def available?
            @subnet.state == 'available'
          end

          # Indicates whether this is the default subnet for the Availability
          # Zone
          def az_default?
            @subnet.default_for_az
          end

          # Indicates whether instances launched in this subnet receive a public
          # IP address
          def with_public_ip_on_launch?
            @subnet.map_public_ip_on_launch
          end

          # The ID of the VPC the subnet is in
          # @return [String]
          def vpc_id
            @subnet.vpc_id
          end

          # The CIDR block assigned to the subnet
          # @return [String]
          def cidr_block
            @subnet.cidr_block
          end

          # The number of unused IP addresses in the subnet. Note that the IP
          # addresses for any stopped instances are considered unavailable
          # @return [Integer]
          def available_ip_address_count
            @subnet.available_ip_address_count
          end

          # The Availability Zone of the subnet
          # @return [String]
          def availability_zone
            @subnet.availability_zone
          end

          # Any tags assigned to the subnet
          # @return [Array(Hash)]
          def tags
            @subnet.tags
          end

          private

          # @private
          def get_subnet(id)
            snets = @aws.describe_subnets(subnet_ids: [id]).subnets
            check_length 'subnets', snets
            @subnet = snets[0]
          end
        end
      end
    end
  end
end
