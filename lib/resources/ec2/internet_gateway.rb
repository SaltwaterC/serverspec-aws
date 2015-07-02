# encoding: utf-8

module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The InternetGateway class exposes the EC2::InternetGateway resources
        class InternetGateway < Base
          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing an
          # InternetGateway resource
          # @param igw_id [String] The ID of the InternetGateway
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if igws.nil?
          # @raise [RuntimeError] if igws.length == 0
          # @raise [RuntimeError] if igws.length > 1
          def initialize(igw_id, instance = nil)
            check_init_arg 'igw_id', 'EC2::InternetGateway', igw_id
            @igw_id = igw_id
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            get_igw igw_id
          end

          # Returns the string representation of EC2::InternetGateway
          # @return [String]
          def to_s
            "EC2 InternetGateway: #{@igw_id}"
          end

          # Returns whether the state of the attachment is available
          def available?
            @igw.attachments[0].state == 'available'
          end

          # The ID of the VPC attached to the InternetGateway
          # @return [String]
          def vpc_id
            @igw.attachments[0].vpc_id
          end

          # Any VPCs attached to the InternetGateway
          # @return [Array(Hash)]
          def attachments
            # usually you shouldn't use this as attachments is returned as
            # Array, but at least the AWS console doesn't allow more than one
            # VPC per InternetGateway
            @igw.attachments
          end

          # Any tags assigned to the InternetGateway
          # @return [Array(Hash)]
          def tags
            @igw.tags
          end

          private

          # @private
          def get_igw(id)
            igws = @aws.describe_internet_gateways(
              internet_gateway_ids: [id]
            ).internet_gateways
            check_length 'internet gateways', igws
            @igw = igws[0]
          end
        end
      end
    end
  end
end
