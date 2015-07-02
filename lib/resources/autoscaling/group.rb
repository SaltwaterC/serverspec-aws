# encoding: utf-8

module Serverspec
  module Type
    module AWS
      # The AutoScaling module contains the AutoScaling API resources
      module AutoScaling
        # The Group class exposes the AutoScaling::Group resources
        class Group < Base
          # AWS SDK for Ruby v2 Aws::AutoScaling::Client wrapper for
          # initializing a Group resource
          # @param group_name [String] The name of the Group
          # @param instance [Class] Aws::AutoScaling::Client instance
          # @raise [RuntimeError] if group_name.nil?
          # @raise [RuntimeError] if groups.length == 0
          # @raise [RuntimeError] if groups.length > 1
          def initialize(group_name, instance = nil)
            check_init_arg 'group_name', 'AutoScaling::Group', group_name
            @group_name = group_name
            @aws = instance.nil? ? Aws::AutoScaling::Client.new : instance
            get_group group_name
          end

          # Returns the String representation of AutoScaling::Group
          def to_s
            "AutoScaling Group: #{@group_name}"
          end

          # The name of the associated LaunchConfiguration
          # @return [String]
          def launch_configuration
            @group.launch_configuration_name
          end

          # The minimum size of the Group
          # @return [Integer]
          def min_size
            @group.min_size
          end

          # The maximum size of the Group
          # @return [Integer]
          def max_size
            @group.max_size
          end

          # The size of the Group
          # @return [Integer]
          def desired_capacity
            @group.desired_capacity
          end

          # The number of seconds after a scaling activity completes before any
          # further scaling activities can start
          # @return [Integer]
          def default_cooldown
            @group.default_cooldown
          end

          # One or more availability zones for the Group
          # @return [Array(String)]
          def availability_zones
            @group.availability_zones
          end

          # One or more LoadBalancers associated with the Group
          # @return [Array(String)]
          def load_balancer_names
            @group.load_balancer_names
          end

          # The service of interest for the health status check, which can be
          # either EC2 or ELB
          # @return [String]
          def health_check_type
            @group.health_check_type
          end

          # The amount of time that AutoScaling waits before checking an
          # instance's health status after being in service
          # @return [Integer]
          def health_check_grace_period
            @group.health_check_grace_period
          end

          # The EC2 Instances associated with the Group
          # @return [Array(Hash)]
          # @example group.instances #=>
          #  [
          #    {
          #      instance_id: 'The ID of the instance',
          #      availability_zone: 'The AZ associated with this instance',
          #      lifecycle_state: 'A description of current lifecycle state',
          #      health_status: 'The health status of the instance',
          #      launch_configuration_name: 'The associated launch config'
          #    }
          #  ]
          def instances
            @group.instances
          end

          # The number of EC2 Instances associated with the Group
          # @return [Integer]
          def instance_count
            @group.instances.length
          end

          # The suspended processes associated with the Group
          # @return [Array(Hash)]
          # @example group.suspended_processes #=>
          #  [
          #    {
          #      process_name: 'The name of the suspended process',
          #      suspension_reason: 'The reason that the process was suspended'
          #    }
          #  ]
          def suspended_processes
            @group.suspended_processes
          end

          # The name of the placement group into which you'll launch your
          # Instances
          # @return [String]
          def placement_group
            @group.placement_group
          end

          # One or more Subnet IDs, if applicable
          # @return [Array(String)]
          def vpc_subnets
            @group.vpc_zone_identifier.split(',').map(&:strip)
          end

          # The metrics enabled for this Group
          # @return [Array(Hash)]
          def enabled_metrics
            @group.enabled_metrics
          end

          # The current state of the Group when a DeleteAutoScalingGroup action
          # is in progress
          # @return [String]
          def status
            @group.status
          end

          # The tags for the Group
          # @return [Array(Hash)]
          def tags
            @group.tags
          end

          # The termination policies for this Group
          # @return [Array(String)]
          def termination_policies
            @group.termination_policies
          end

          # The policies for the Group
          # @return [Array(Hash)]
          def scaling_policies
            @aws.describe_policies(
              auto_scaling_group_name: @group_name
            ).scaling_policies
          end

          private

          # @private
          def get_group(name)
            groups = @aws.describe_auto_scaling_groups(
              auto_scaling_group_names: [name]
            ).auto_scaling_groups
            check_length 'autoscaling groups', groups
            @group = groups[0]
          end
        end
      end
    end
  end
end
