# encoding: utf-8

# Inspired by https://github.com/stelligent/serverspec-aws-resources

module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The Subnets class provides serverspec expectations for a collection
        # of EC2::Subnet resources
        class Subnets < Base
          def initialize(subnets)
            @subnets = subnets
          end

          def evenly_spread_across_minimum_az?(num_azs)
            subnet_grouping_by_az = @subnets.group_by(&:availability_zone)
            return false if
              number_of_sizes_in_sub_arrays(subnet_grouping_by_az) != 1

            return false if
              subnet_grouping_by_az.size < num_azs

            true
          end

          private

          def number_of_sizes_in_sub_arrays(arr)
            arr.map(&:size).uniq.size
          end
        end
      end
    end
  end
end
