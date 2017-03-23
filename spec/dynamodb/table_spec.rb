key_schema = [
  {
    attribute_name: 'test-hash-attrib',
    key_type: 'HASH'
  },
  {
    attribute_name: 'test-range-attrib',
    key_type: 'RANGE'
  }
]

attribute_definitions = [
  {
    attribute_name: 'test-hash-attrib',
    attribute_type: 'S'
  },
  {
    attribute_name: 'test-range-attrib',
    attribute_type: 'N'
  }
]

provisioned_throughput = {
  last_increase_date_time: Time.new(0),
  last_decrease_date_time: Time.new(0),
  number_of_decreases_today: 0,
  read_capacity_units: 64,
  write_capacity_units: 32
}

local_secondary_indexes = [
  {
    index_name: 'test-lsi',
    key_schema: key_schema,
    projection: {
      projection_type: 'ALL',
      non_key_attributes: []
    },
    index_size_bytes: 512,
    item_count: 32
  }
]

global_secondary_indexes = [
  {
    index_name: 'test-gsi',
    key_schema: key_schema,
    projection: {
      projection_type: 'ALL',
      non_key_attributes: []
    },
    index_status: 'ACTIVE',
    backfilling: false,
    provisioned_throughput: provisioned_throughput,
    index_size_bytes: 512,
    item_count: 32
  }
]

dynamodb = Aws::DynamoDB::Client.new
dynamodb.stub_responses(
  :describe_table,
  table: {
    table_status: 'ACTIVE',
    attribute_definitions: attribute_definitions,
    key_schema: key_schema,
    local_secondary_indexes: local_secondary_indexes,
    global_secondary_indexes: global_secondary_indexes,
    provisioned_throughput: provisioned_throughput
  }
)

RSpec.describe table = DynamoDB::Table.new('test-table', dynamodb) do
  its(:to_s) { is_expected.to eq 'DynamoDB Table: test-table' }

  it { is_expected.to be_valid }
  it { is_expected.to be_with_hash_key }
  it { is_expected.to be_with_range_key }
  it { is_expected.to be_local_secondary_indexed }
  it { is_expected.to be_global_secondary_indexed }

  its(:attribute_definitions) do
    attr_def = []
    table.attribute_definitions.each do |attr|
      attr_def << attr.to_h
    end
    expect(attr_def).to eq attribute_definitions
  end

  its(:key_schema) do
    key_sch = []
    table.key_schema.each do |ks|
      key_sch << ks.to_h
    end
    expect(key_sch).to eq key_schema
  end

  its(:read_capacity) { is_expected.to eq 64 }
  its(:write_capacity) { is_expected.to eq 32 }

  its(:local_secondary_indexes) do
    lsi = table.local_secondary_indexes[0].to_h
    expect([lsi]).to eq local_secondary_indexes
  end

  its(:global_secondary_indexes) do
    gsi = table.global_secondary_indexes[0].to_h
    expect([gsi]).to eq global_secondary_indexes
  end

  its(:hash_key_name) { is_expected.to eq 'test-hash-attrib' }
  its(:hash_key_type) { is_expected.to eq :string }

  its(:range_key_name) { is_expected.to eq 'test-range-attrib' }
  its(:range_key_type) { is_expected.to eq :number }
end
