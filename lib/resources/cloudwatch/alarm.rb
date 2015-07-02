# encoding: utf-8

module Serverspec
  module Type
    module AWS
      # The CloudWatch module contains the CloudWatch API resources
      module CloudWatch
        # The Alarm class exposes the CloudWatch::Alarm resources
        class Alarm < Base
          # AWS SDK for Ruby v2 Aws::CloudWatch::Client wrapper for initializing
          # an Alarm resource
          # @param alarm_name [String] The name of the Alarm
          # @param instance [Class] Aws::CloudWatch::Client instance
          # @raise [RuntimeError] if alarm_name.nil?
          # @raise [RuntimeError] if alarms.length == 0
          # @raise [RuntimeError] if alarms.length > 1
          def initialize(alarm_name, instance = nil)
            check_init_arg 'alarm_name', 'CloudWatch::Alarm', alarm_name
            @alarm_name = alarm_name
            @aws = instance.nil? ? Aws::CloudWatch::Client.new : instance
            get_alarm alarm_name
          end

          # Returns the String representation of CloudWatch::Alarmm
          # @return [String]
          def to_s
            "CloudWatch Alarm: #{@alarm_name}"
          end

          # Checks if the Alarm state is OK
          def ok?
            @alarm.state_value == 'OK'
          end

          # Indicates whether actions should be executed during any changes to
          # the Alarm's state
          def actions_enabled?
            @alarm.actions_enabled
          end

          # The description for the Alarm
          # @return [String]
          def alarm_description
            @alarm.alarm_description
          end

          # The list of actions to execute when this Alarm transitions into an
          # OK state from any other state
          # @return [Array(String)]
          def ok_actions
            @alarm.ok_actions
          end

          # The list of actions to execute when this Alarm transitions into an
          # ALARM state from any other state
          # @return [Array(String)]
          def alarm_actions
            @alarm.alarm_actions
          end

          # The list of actions to execute when this Alarm transitions into an
          # INSUFFICIENT_DATA state from any other state
          # @return [Array(String)]
          def insufficient_data_actions
            @alarm.insufficient_data_actions
          end

          # The name of the Alarm's metric
          # @return [String]
          def metric_name
            @alarm.metric_name
          end

          # The namespace of Alarm's associated metric
          # @return [String]
          def namespace
            @alarm.namespace
          end

          # The statistic to apply to the Alarm's associated metric
          # @return [String]
          def statistic
            @alarm.statistic
          end

          # The list of dimensions associated with the Alarm's associated metric
          # @return [Array(Hash{Symbol => String})]
          # @example alarm.dimensions #=>
          #  [
          #    {
          #      name: 'The name of the dimension',
          #      value: 'The value representing the dimension measurement'
          #    }
          #  ]
          def dimensions
            @alarm.dimensions
          end

          # The period in seconds over which the statistic is applied
          # @return [Integer]
          def period
            @alarm.period
          end

          # The number of periods over which data is compared to the specified
          # threshold
          # @return [Integer]
          def evaluation_periods
            @alarm.evaluation_periods
          end

          # The value against which the specified statistic is compared
          # @return [Number]
          def threshold
            @alarm.threshold
          end

          # The arithmetic operation to use when comparing the specified
          # Statistic and Threshold
          # @return [String]
          def comparison_operator
            @alarm.comparison_operator
          end

          private

          # @private
          def get_alarm(name)
            als = @aws.describe_alarms(alarm_names: [name]).metric_alarms
            check_length 'alarms', als
            @alarm = als[0]
          end
        end
      end
    end
  end
end
