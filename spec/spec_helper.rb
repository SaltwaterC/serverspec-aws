# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 5
  config.order = :random
  Kernel.srand config.seed
end

require_relative '../lib/serverspec-aws'
include Serverspec::Type::AWS
set :backend, :exec

# without this bit, the SDK is painfully slow
Aws.config.update(
  region: 'us-east-1',
  credentials: Aws::Credentials.new('akid', 'secret')
)

# the client stubbing makes these tests possible
Aws.config[:stub_responses] = true
