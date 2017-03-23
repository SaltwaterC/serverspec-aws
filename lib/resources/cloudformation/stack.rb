module Serverspec
  module Type
    module AWS
      # The CloudFormation module contains the AutoScaling API resources
      module CloudFormation
        # The Stack class exposes the CloudFormation::Stack resources
        class Stack < Base
          # AWS SDK for Ruby v2 Aws::CloudFormation::Client wrapper for
          # initializing a Stack resource
          # @param stack_name [String] The name of the Stack
          # @param instance [Class] Aws::CloudFormation::Client instance
          # @raise [RuntimeError] if stack_name.nil?
          # @raise [RuntimeError] if stacks.length == 0
          # @raise [RuntimeError] if stacks.length > 1
          def initialize(stack_name, instance = nil)
            check_init_arg 'stack_name', 'CloudFormation::Stack', stack_name
            @stack_name = stack_name
            @aws = instance.nil? ? Aws::CloudFormation::Client.new : instance
            get_stack stack_name
          end

          # Returns the String representation of CloudFormation::Stack
          # @return [String]
          def to_s
            "CloudFormation Stack: #{@stack_name}"
          end

          # Check whether the rollback on Stack creation failures is disabled
          def rollback_disabled?
            @stack.disable_rollback
          end

          # Check if the Stack is in CREATE_COMPLETE or UPDATE_COMPLETE status
          def ok?
            @stack.stack_status == 'CREATE_COMPLETE' ||
              @stack.stack_status == 'UPDATE_COMPLETE'
          end

          # User defined description associated with the Stack
          # @return [String]
          def description
            @stack.description
          end

          # A list of Parameter structures
          # @return [Array(Hash)]
          def parameters
            @stack.parameters
          end

          # Current status of the Stack
          # @return [String]
          def stack_status
            @stack.stack_status
          end

          # SNS topic ARNs to which Stack related events are published
          # @return [Array(String)]
          def notification_arns
            @stack.notification_arns
          end

          # The amount of time within which Stack creation should complete
          # @return [Integer]
          def timeout_in_minutes
            @stack.timeout_in_minutes
          end

          # The capabilities allowed in the Stack
          # @return [Array(String)]
          def capabilities
            @stack.capabilities
          end

          # A list of output structures
          # @return [Array(Hash)]
          def outputs
            @stack.outputs
          end

          # A list of tags that specify cost allocation information for the
          # Stack
          # @return [Array(Hash)]
          def tags
            @stack.tags
          end

          private

          # @private
          def get_stack(name)
            stacks = @aws.describe_stacks(stack_name: name).stacks
            check_length 'stacks', stacks
            @stack = stacks[0]
          end
        end
      end
    end
  end
end
