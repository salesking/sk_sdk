require 'rubygems'
require 'yaml'
require 'rspec'
require "active_support"
require "active_support/json"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/base"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/sync"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/oauth"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/signed_request"


puts "Testing with ActiveResource v: #{ActiveResource::VERSION::STRING}"


def basic_auth_settings
  get_settings['basic_auth'].symbolize_keys
end

def oauth_settings
  get_settings['oauth']
end

def get_settings
  @settings ||= begin 
    YAML.load_file(File.join(File.dirname(__FILE__), 'settings.yml')) 
    rescue => e
    puts "Missing settings.yml in rails_root/spec/settings.yml"
  end
end
