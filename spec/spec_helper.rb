# encoding: utf-8
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'simplecov'
SimpleCov.start 'rails'
SimpleCov.coverage_dir 'coverage'

require 'sk_sdk'
require 'sk_sdk/base'
require 'sk_sdk/sync'
require 'sk_sdk/oauth'
require 'sk_sdk/signed_request'
require 'rubygems'
require 'yaml'
require 'rspec'
require 'active_support'
require 'active_support/json'

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
      raise 'Missing settings.yml in spec/settings.yml'
  end
end
