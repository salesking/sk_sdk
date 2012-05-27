require 'rubygems'
require 'sk_sdk'
require 'active_resource'
require 'active_resource/version'
# patches are for specific AR version
if ActiveResource::VERSION::MAJOR == 3
  require 'sk_sdk/ar_patches/ar3/base'
  require 'sk_sdk/ar_patches/ar3/validations'
elsif ActiveResource::VERSION::MAJOR < 3
  require 'sk_sdk/ar_patches/ar2/validations'
  require 'sk_sdk/ar_patches/ar2/base'
end

class SK::SDK::Base < ActiveResource::Base
  self.format = :json
  # hook before init in activeresource base because json comes in nested:
  # {client={data}
  if ActiveResource::VERSION::MAJOR == 3 && ActiveResource::VERSION::MINOR > 0
    def initialize(attributes = {}, *args)
      attr = attributes[self.class.element_name] || attributes
      super(attr, *args)
    end
  else
    def initialize(attributes = {})
      attr = attributes[self.class.element_name] || attributes
      super(attr)
    end
  end

  def save; save_with_validation; end

  # Define the connection to be used when talking to a salesking server
  #
  # @param[Hash{Symbol=>String}] opts
  # @option [String] :site SalesKing Url, required
  # @option [String] :token oAuth2 access token, added to the request header
  #   if set user/pass are not needed, so this is what you should be using!
  # @option [String] :user if using httpBasic auth set to sk user login email
  # @option [String] :password if using httpBasic sk user password
  def self.set_connection(opts)
    self.site   = site_api_url(opts[:site])
    self.format = :json # f*** xml
    if opts[:token] #oAuth access token in header
      self.headers['Authorization'] = "Bearer #{opts[:token]}"
    else
      self.user     = opts[:user]
      self.password = opts[:password]
    end
  end

  # If headers are not defined in a given subclass, then obtain
  # headers from the superclass.
  def self.headers
    if defined?(@headers)
      @headers
    elsif superclass != Object && superclass.headers
      superclass.headers
    else
      @headers ||= {}
    end
  end

  private

  def self.site_api_url(site)
    site = site.gsub(/\/$/, '')
    site =~ /\/api$/ ? site : "#{site}/api"
  end
end
