# encoding: utf-8

ec2 = Aws::EC2::Client.new
# stub RouteTable
ec2.stub_responses(:describe_route_tables, route_tables: [
  {
    vpc_id: 'vpc-aabbccdd',
    routes: [
      {
        destination_cidr_block: '10.0.0.0/16',
        state: 'active',
        origin: 'CreateRouteTable'
      }
    ],
    associations: [
      {
        route_table_association_id: 'rtbassoc-aabbccdd',
        route_table_id: 'rtb-aabbccdd',
        main: true
      }
    ],
    tags: [
      {
        key: 'Name',
        value: 'test-route-table'
      }
    ]
  }
])

RSpec.describe rtb = EC2::RouteTable.new('rtb-aabbccdd', ec2) do
  its(:to_s) { is_expected.to eq 'EC2 RouteTable: rtb-aabbccdd' }
  its(:vpc_id) { is_expected.to eq 'vpc-aabbccdd' }

  its(:routes) do
    route = rtb.routes[0]
    expect(route.destination_cidr_block).to eq '10.0.0.0/16'
    expect(route.state).to eq 'active'
    expect(route.origin).to eq 'CreateRouteTable'
  end

  its(:associations) do
    assoc = rtb.associations[0]
    expect(assoc.route_table_association_id).to eq 'rtbassoc-aabbccdd'
    expect(assoc.route_table_id).to eq 'rtb-aabbccdd'
    expect(assoc.main).to eq true
  end

  its(:tags) do
    tag = rtb.tags[0]
    expect(tag.key).to eq 'Name'
    expect(tag.value).to eq 'test-route-table'
  end

  its(:propagating_vgws) { is_expected.to eq [] }
end
