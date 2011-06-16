require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rspec'
require 'rspec/core/rake_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sk_sdk"
    gem.summary = %Q{SalesKing SDK Ruby}
    gem.description = %Q{Connect your business world with SalesKing. This gem gives ruby developers a jump-start for building SalesKing Business Apps. It provides classes to handle oAuth, make RESTfull API requests and parses JSON Schema  }
    gem.email = "gl@salesking.eu"
    gem.homepage = "http://github.com/salesking/sk_sdk"
    gem.authors = ["Georg Leciejewski"]
    gem.add_dependency 'curb'
    gem.add_dependency 'activesupport'
    gem.add_dependency 'sk_api_schema'
    gem.add_dependency 'activeresource'
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "rcov"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SalesKing SDK'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
