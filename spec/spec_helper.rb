require 'rubygems'
require 'yaml'
require 'spec'
require "active_support"
require "active_support/json"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/oauth"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/signed_request"
require "#{File.dirname(__FILE__)}/../lib/sk_sdk/ar_cli"


puts "Testing with ActiveResource v: #{ActiveResource::VERSION::STRING}."


def load_settings
  @set ||= YAML.load_file(File.join(File.dirname(__FILE__), 'settings.yml'))
end

CONNECTION = {
    :site => "http://demo.salesking.local:3000/api/",
    :user => "demo@salesking.eu",
    :password => "demo",
    :format => :json
} unless defined?(CONNECTION)

def sk_available?
  SK::SDK::ArCli.make(:user) unless Object.const_defined?('User')
  User.set_connection( CONNECTION )
  begin
    User.get(:current)
  rescue Errno::ECONNREFUSED #ActiveResource::ResourceNotFound => e
    return false
  end

end