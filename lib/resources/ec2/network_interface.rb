# encoding: utf-8

module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The NetworkInterface class exposes the EC2::NetworkInterface resources
        class NetworkInterface < Base
          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing a
          # NetworkInterface resource
          # @param ni_id [String] The ID of the NetworkInterface
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if nis.nil?
          # @raise [RuntimeError] if nis.length == 0
          # @raise [RuntimeError] if nis.length > 1
          def initialize(ni_id, instance = nil)
            check_init_arg 'ni_id', 'EC2::NetworkInterface', ni_id
            @ni_id = ni_id
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            get_ni ni_id
          end

          # Returns the string representation of EC2::NetworkInterface
          # @return [String]
          def to_s
            "EC2 NetworkInterface: #{@ni_id}"
          end

          # Returns whether the NetworkInterface is attached
          def attached?
            @ni.attachment.status == 'attached'
          end

          # Indicates whether the NetworkInterface is being managed by AWS
          def requester_managed?
            @ni.requester_managed
          end

          # Indicates whether the status is in-use
          def in_use?
            @ni.status == 'in-use'
          end

          # Indicates whether traffic to or from the Instance is validated
          def source_dest_checked?
            @ni.source_dest_check
          end

          # The ID of the Subnet
          # @return [String]
          def subnet_id
            @ni.subnet_id
          end

          # The ID of the VPC
          # @return [String]
          def vpc_id
            @ni.vpc_id
          end

          # The availability zone
          # @return [String]
          def availability_zone
            @ni.availability_zone
          end

          # The description
          # @return [String]
          def description
            @ni.description
          end

          # The AWS account ID of the owner of the NetworkInterface
          # @return [String]
          def owner_id
            @ni.owner_id
          end

          # The ID of the entity that launched the instance on your behalf (eg:
          # AWS Management Console, Auto Scaling)
          # @return [String]
          def requester_id
            @ni.requester_id
          end

          # The status
          # @return [String]
          def status
            @ni.status
          end

          # The MAC address
          # @return [String]
          def mac_address
            @ni.mac_address
          end

          # The private IP address within the Subnet
          # @return [String]
          def private_ip_address
            @ni.private_ip_address
          end

          # The private DNS name
          # @return [String]
          def private_dns_name
            @ni.private_dns_name
          end

          # Any SecurityGroups for the NetworkInterface
          # @return [Array(Hash)]
          def groups
            @ni.groups
          end

          # The NetworkInterface attachment
          # @return [Hash]
          def attachment
            @ni.attachment
          end

          # The association information for an Elastic IP associated to the
          # NetworkInterface
          # @return [Hash]
          def association
            @ni.association
          end

          # Any tags associated to the NetworkInterface
          # @return [Array(Hash)]
          def tags
            @ni.tag_set
          end

          # The private IP addresses associated with the NetworkInterface
          # @return [Array(Hash)]
          def private_ip_addresses
            @ni.private_ip_addresses
          end

          private

          # @private
          def get_ni(id)
            nis = @aws.describe_network_interfaces(
              network_interface_ids: [id]
            ).network_interfaces
            check_length 'network interfaces', nis
            @ni = nis[0]
          end
        end
      end
    end
  end
end
