# encoding: utf-8

# Jeweler stuff
begin
  require 'jeweler'
  require_relative 'lib/serverspec-aws'
  Jeweler::Tasks.new do |gem|
    gem.name        = 'serverspec-aws'
    gem.version     = Serverspec::Type::AWS::VERSION
    gem.summary     = %(Serverspec for AWS)
    gem.description = %(Serverspec resources for testing the AWS infrastructure)
    gem.author      = 'Ștefan Rusu'
    gem.email       = 'saltwaterc@gmail.com'
    gem.files       = Dir['lib/*.rb'] + Dir['lib/resources/*.rb']
    gem.license     = 'BSD-3-Clause'
    gem.homepage    = 'https://github.com/SaltwaterC/serverspec-aws'
  end
rescue LoadError
  STDERR.puts 'Jeweler, or one of its dependencies, is not available.'
end

begin
  # Rubocop stuff
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  STDERR.puts 'Rubocop, or one of its dependencies, is not available.'
end

# Rspec stuff
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  STDERR.puts 'RSpec, or one of its dependencies, is not available.'
end

# Guard stuff
desc 'Executes guard'
task :guard do
  # outdated documentation is outdated
  # require 'guard'
  # Guard.run_all
  system 'guard'
end

begin
  # YARD stuff
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  STDERR.puts 'YARD, or one of its dependencies, is not available.'
end

desc 'Runs the cleanup task, then the YARD server'
task yardserver: [:cleanup] do
  system 'yard server --reload'
end

# Cleanup stuff
desc 'Delete all temporary files'
task :cleanup do
  rm_rf '.yardoc'
  rm_rf 'doc'
  rm_rf 'pkg'
  rm_f 'serverspec-aws.gemspec'
  rm_f 'Gemfile.lock'
end

desc 'Runs the rubocop and the spec tasks'
task test: [:rubocop, :spec]

# Testing stuff
task default: [:test]
