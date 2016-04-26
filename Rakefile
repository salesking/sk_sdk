require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks

desc "Run specs"
RSpec::Core::RakeTask.new
task :default => :spec
