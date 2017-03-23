module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The RouteTable class exposes the EC2::RouteTable resources
        class RouteTable < Base
          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing a
          # RouteTable resource
          # @param rtb_id [String] The ID of the RouteTable
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if rtbs.nil?
          # @raise [RuntimeError] if rtbs.length == 0
          # @raise [RuntimeError] if rtbs.length > 1
          def initialize(rtb_id, instance = nil)
            check_init_arg 'rtb_id', 'EC2::RouteTable', rtb_id
            @rtb_id = rtb_id
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            get_rtb rtb_id
          end

          # Returns the string representation of EC2::RouteTable
          # @return [String]
          def to_s
            "EC2 RouteTable: #{@rtb_id}"
          end

          # The ID of the VPC
          # @return [String]
          def vpc_id
            @rtb.vpc_id
          end

          # The routes in the route table
          # @return [Array(Hash)]
          def routes
            @rtb.routes
          end

          # The associations between the route table and one or more subnets
          # @return [Array(Hash)]
          def associations
            @rtb.associations
          end

          # Any tags assigned to the route table
          # @return [Array(Hash)]
          def tags
            @rtb.tags
          end

          # Any virtual private gateway (VGW) propagating routes
          # @return [Array(Hash)]
          def propagating_vgws
            @rtb.propagating_vgws
          end

          private

          # @private
          def get_rtb(id)
            rtbs = @aws.describe_route_tables(
              route_table_ids: [id]
            ).route_tables
            check_length 'route tables', rtbs
            @rtb = rtbs[0]
          end
        end
      end
    end
  end
end
