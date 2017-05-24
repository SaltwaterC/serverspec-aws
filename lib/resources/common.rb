# The Serverspec module contains all the Serverspec resources
module Serverspec
  # The Type module contains the Serverspec types
  module Type
    # The AWS module contains all the AWS API resources
    module AWS
      # The Serverspec::Type::AWS::VERSION constant actually sets this library
      # version in the format: major.minor.patch.build
      VERSION = '0.1.2'.freeze

      # Check if the initialization argument of an AWS resource class is present
      # @param arg_name [String] - The name of the init argument
      # @param class_name [String] - The name of the AWS resource class
      # @param arg [String] - The arg passed to the class constructor
      # @raise [RuntimeError] if arg.nil?
      def check_init_arg(arg_name, class_name, arg)
        raise "Must specify #{arg_name} for #{class_name}" if arg.nil?
      end

      # Check the length for operations that should return only one resource
      # @param item_name [String] - The name of the item to check
      # @param item [Array] - The actual item for checking the length
      # @raise [RuntimeError] if item.length == 0
      # @raise [RuntimeError] if item.length > 1
      def check_length(item_name, item)
        return if item.length == 1

        if item.empty?
          raise "No #{item_name} with the specified name were"\
            'returned'
        else
          raise "Multiple #{item_name} with the same name "\
               'were returned'
        end
      end
    end
  end
end
