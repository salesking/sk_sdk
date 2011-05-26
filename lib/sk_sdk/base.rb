require 'rubygems'
require 'sk_sdk'
require 'active_resource'
require 'active_resource/version'
# patches are for specific AR version
if ActiveResource::VERSION::MAJOR == 3
  require 'sk_sdk/ar_cli/patches/ar3/base'
  require 'sk_sdk/ar_cli/patches/ar3/validations'
elsif ActiveResource::VERSION::MAJOR < 3
  require 'sk_sdk/ar_cli/patches/ar2/validations'
  require 'sk_sdk/ar_cli/patches/ar2/base'
end

class SK::SDK::Base < ActiveResource::Base
  self.format = :json
  # hook before init in activeresource base because json comes in nested:
  # {client={data}
  def initialize(attributes = {})
    attr = attributes[self.class.element_name] || attributes
    super(attr)
  end

  def save; save_with_validation; end

  # Define the connection to be used when talking to a salesking server
  def self.set_connection(opts)
    self.site     = opts[:site]
    self.user     = opts[:user]
    self.password = opts[:password]
    self.format   = opts[:format].to_sym
  end

end