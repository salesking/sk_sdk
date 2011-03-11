require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sk_sdk"
    gem.summary = %Q{SalesKing SDK Ruby}
    gem.description = %Q{Connect your business world with SalesKing. This gem gives ruby developers a jump-start for building SalesKing Business Apps. Under the hood it provides classes to handle oAuth, make RESTfull API requests and parses JSON Schema  }
    gem.email = "gl@salesking.eu"
    gem.homepage = "http://github.com/salesking/sk_sdk"
    gem.authors = ["Georg Leciejewski"]
    gem.add_dependency 'curb'
    gem.add_dependency 'activesupport'
#    gem.add_dependency 'sk_api_schema'
#    gem.add_dependency 'sk_api_builder'
#    gem.add_dependency 'activeresource'
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "rcov"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'Default: run specs.'
task :default => :spec

spec_files = Rake::FileList["spec/**/*_spec.rb"]

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = spec_files
  t.spec_opts = ["-c"]
end

desc "Generate code coverage"
Spec::Rake::SpecTask.new(:coverage) do |t|
  t.spec_files = spec_files
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/var/lib/gems,/usr/local/lib']
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SalesKing SDK'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
