#!/usr/bin/env rake
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'stove/rake_task'
Stove::RakeTask.new
require 'foodcritic'

# Style tests. Rubocop and Foodcritic
namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)

  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef) do |t|
    t.options = {
      fail_tags: ['any'],
      exclude_paths: ['spec/', 'test/']
    }
  end
end

desc 'Run all style checks'
task :style => %w( style:chef style:ruby )

# Rspec and ChefSpec
desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end
end

task :travis => %w( style:chef spec )

task :test => %w( style:chef spec integration:vagrant )
