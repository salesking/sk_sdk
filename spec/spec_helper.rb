require 'rubygems'
require 'yaml'
require 'spec'
require "active_support"
require "active_support/json"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/oauth"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/signed_request"

def load_settings
  @set ||= YAML.load_file(File.join(File.dirname(__FILE__), 'settings.yml'))
end
