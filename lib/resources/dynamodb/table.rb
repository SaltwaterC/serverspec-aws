module Serverspec
  module Type
    module AWS
      # The DynamoDB module contains the DynamoDB API resources
      module DynamoDB
        # The Table class exposes the DynamoDB::Table resources
        class Table < Base
          # AWS SDK for Ruby v2 Aws::DynamoDB::Client wrapper for initializing
          # a Table resource
          # @param tbl_name [String] The name of the Table
          # @param instance [Class] Aws::DynamoDB::Client instance
          # @raise [RuntimeError] if tbl_name.nil?
          # @raise [ResourceNotFoundException] if table.nil?
          def initialize(tbl_name, instance = nil)
            check_init_arg 'tbl_name', 'DynamoDB::Table', tbl_name
            @tbl_name = tbl_name
            @aws = instance.nil? ? Aws::DynamoDB::Client.new : instance
            get_table tbl_name

            @type_map = {
              'S' => :string,
              'N' => :number,
              'B' => :binary
            }
          end

          # Returns the String representation of DynamoDB::Table
          # @return [String]
          def to_s
            "DynamoDB Table: #{@tbl_name}"
          end

          # Returns true if the Table is active
          def valid?
            @table.table_status == 'ACTIVE'
          end

          # Returns true if the Table has a hash key
          def with_hash_key?
            key_type?('hash')
          end

          # Returns true if the Table has a range key
          def with_range_key?
            key_type?('range')
          end

          # Returns true if there is a local secondary index
          def local_secondary_indexed?
            @table.local_secondary_indexes.is_a?(Array)
          end

          # Returns true if there is a global secondary index
          def global_secondary_indexed?
            @table.global_secondary_indexes.is_a?(Array)
          end

          # An array of AttributeDefinition objects. Each of these objects
          # describes one attribute in the Table and index key schema
          # @return [Array(Hash)]
          def attribute_definitions
            @table.attribute_definitions
          end

          # The primary key structure for the Table
          # @return [Array(Hash)]
          def key_schema
            @table.key_schema
          end

          # The maximum number of strongly consistent reads consumed per second
          # before DynamoDB returns a ThrottlingException
          # @return [Integer]
          def read_capacity
            @table.provisioned_throughput.read_capacity_units
          end

          # The maximum number of writes consumed per second before DynamoDB
          # returns a ThrottlingException
          # @return [Integer]
          def write_capacity
            @table.provisioned_throughput.write_capacity_units
          end

          # Represents one or more local secondary indexes on the Table. Each
          # index is scoped to a given hash key value
          # @return [Array(Hash)]
          def local_secondary_indexes
            @table.local_secondary_indexes
          end

          # The global secondary indexes, if any, on the Table. Each index is
          # scoped to a given hash key value
          # @return [Array(Hash)]
          def global_secondary_indexes
            @table.global_secondary_indexes
          end

          # The name of the hash key from the key_schema
          # @return [String]
          def hash_key_name
            @table.key_schema.each do |key|
              return key.attribute_name if key.key_type == 'HASH'
            end
          end

          # The type of the hash key from the key_schema. Valid return values:
          # :string, :number, or :binary
          # @return [Symbol]
          def hash_key_type
            @table.attribute_definitions.each do |attr|
              if attr.attribute_name == hash_key_name
                return @type_map[
                  attr.attribute_type
                ]
              end
            end
          end

          # The name of the range key from the key_schema
          # @return [String]
          def range_key_name
            @table.key_schema.each do |key|
              return key.attribute_name if key.key_type == 'RANGE'
            end
          end

          # The type of the range key from the key_schema. Valid return values:
          # :string, :number, or :binary
          # @return [Symbol]
          def range_key_type
            @table.attribute_definitions.each do |attr|
              if attr.attribute_name == range_key_name
                return @type_map[
                  attr.attribute_type
                ]
              end
            end
          end

          private

          # @private
          def get_table(name)
            @table = @aws.describe_table(table_name: name).table
          end

          # @private
          def key_type?(type)
            @table.key_schema.each do |key|
              return true if key.key_type.casecmp(type)
            end
            false
          end
        end
      end
    end
  end
end
