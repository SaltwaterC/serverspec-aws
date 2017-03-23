group :red_green_refactor, halt_on_fail: true do
  guard :rubocop

  guard :rspec, cmd: 'rspec' do
    watch('spec/spec_helper.rb') { 'spec' }
    watch(%r{^lib/resources/(.+)/(.+)\.rb$}) do |m|
      "spec/#{m[1]}/#{m[2]}_spec.rb"
    end
    watch(%r{^spec/.+/.+\.rb$})
  end
end
