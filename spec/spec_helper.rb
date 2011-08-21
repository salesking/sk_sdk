require 'rubygems'
require 'yaml'
require 'rspec'
require "active_support"
require "active_support/json"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/base"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/field_sync"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/oauth"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/signed_request"


puts "Testing with ActiveResource v: #{ActiveResource::VERSION::STRING}"


def load_settings
  @set ||= YAML.load_file(File.join(File.dirname(__FILE__), 'settings.yml'))
end
