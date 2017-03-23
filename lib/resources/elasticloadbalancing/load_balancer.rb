module Serverspec
  module Type
    module AWS
      # The ElasticLoadBalancing module contains the ElasticLoadBalancing API
      # resources
      module ElasticLoadBalancing
        # The LoadBalancer class exposes the ElasticLoadBalancing::LoadBalancer
        # resources
        class LoadBalancer < Base
          # AWS SDK for Ruby v2 Aws::ElasticLoadBalancing::LoadBalancer wrapper
          # for initializing a LoadBalancer resource
          # @param elb_name [String] The name of the LoadBalancer
          # rubocop:disable LineLength
          # @param instance [Class] Aws::ElasticLoadBalancing::LoadBalancer instance
          # rubocop:enable LineLength
          # @raise [RuntimeError] if elbs.nil?
          # @raise [RuntimeError] if elbs.length == 0
          # @raise [RuntimeError] if elbs.length > 1
          def initialize(elb_name, instance = nil)
            check_init_arg(
              'elb_name',
              'ElasticLoadBalancing::LoadBalancer',
              elb_name
            )
            @elb_name = elb_name
            get_instance instance
            get_elb elb_name
          end

          # Returns the string representation of
          # ElasticLoadBalancing::LoadBalancer
          # @return [String]
          def to_s
            "ElasticLoadBalancing LoadBalancer: #{@elb_name}"
          end

          # Indicates whether the scheme is internal
          def internal?
            @elb.scheme == 'internal'
          end

          # Indicates whether the scheme is internet-facing
          def internet_facing?
            @elb.scheme == 'internet-facing'
          end

          # The external DNS name of the load balancer
          # @return [String]
          def dns_name
            @elb.dns_name
          end

          # The Amazon Route 53 hosted zone associated with the load balancer
          # @return [String]
          def canonical_hosted_zone_name
            @elb.canonical_hosted_zone_name
          end

          # The ID of the Amazon Route 53 hosted zone name associated with the
          # load balancer
          # @return [String]
          def canonical_hosted_zone_name_id
            @elb.canonical_hosted_zone_name_id
          end

          # The listeners for the load balancer
          # @return [Array(Hash)]
          def listeners
            @elb.listener_descriptions
          end

          # The policies defined for the load balancer
          # @return [Hash]
          def policies
            @elb.policies
          end

          # Information about the back-end servers
          # @return [Array(Hash)]
          def backend_server_descriptions
            @elb.backend_server_descriptions
          end

          # The Availability Zones for the load balancer
          # @return [Array(String)]
          def availability_zones
            @elb.availability_zones
          end

          # The IDs of the subnets for the load balancer
          # @return [Array(String)]
          def subnets
            @elb.subnets
          end

          # The ID of the VPC for the load balancer
          # @return [String]
          def vpc_id
            @elb.vpc_id
          end

          # The IDs of the instances for the load balancer
          # @return [Array(Hash)]
          def instances
            instances = []
            @elb.instances.each do |inst|
              instances << inst.instance_id
            end
            instances
          end

          # Information about the health checks conducted on the load balancer
          # @return [Hash]
          def health_check
            @elb.health_check
          end

          # The security group that you can use as part of your inbound rules
          # for your load balancer's back-end application instances. To only
          # allow traffic from load balancers, add a security group rule to your
          # back end instance that specifies this source security group as the
          # inbound source
          # @return [Hash]
          def source_security_group
            @elb.source_security_group
          end

          # The security groups for the load balancer. Valid only for load
          # balancers in a VPC
          # @return [Array(String)]
          def security_groups
            @elb.security_groups
          end

          private

          # @private
          def get_elb(name)
            elbs = @aws.describe_load_balancers(
              load_balancer_names: [name]
            ).load_balancer_descriptions
            check_length 'load balancers', elbs
            @elb = elbs[0]
          end

          # @private
          def get_instance(instance)
            @aws = (
              instance.nil? ? Aws::ElasticLoadBalancing::Client.new : instance
            )
          end
        end
      end
    end
  end
end
