require 'rubygems'
require 'active_resource'
require 'active_resource/version'
# patches are for specific AR version
if ActiveResource::VERSION::MAJOR == 3
  require 'sk_sdk/ar_client/patches/ar3/base'
  require 'sk_sdk/ar_client/patches/ar3/validations'
elsif ActiveResource::VERSION::MAJOR < 3
  require 'sk_sdk/ar_client/patches/ar2/validations'
  require 'sk_sdk/ar_client/patches/ar2/base'
end

# schema gem
#require 'sk_api_schema'

module SK::SDK
  class ArClient
    # Create a class for a given name
    #
    # === Example
    #
    #  SK::API::Builder.make(:client)
    #  => reads sk_api_schema/json/v1.0/client.json and makes a class available:
    #  c = Client.new
    #
    #  SK::API::Builder.make(:invoice, SK::API) MyClientMiddelware::Invoice.new
    #  => resk_api_ads sk_api_schema/json/v1.0/invoice.json and makes a class available:
    #  i = SK::API::Invoice.new
    #
    # === Parameter
    # name<String>:: lowercase, underscored name: line_item, client must be a
    # valid title of a json schema
    # obj_scope<Constant>:: class, module name under which to setup(namespace)
    #  the new class. Default to Object, example: SK::API
    def self.make(name, obj_scope =nil)
      class_name = name.to_s.camelize
      # by default create class in Object scope
      obj_scope ||= Object
      # only define the class once
      raise "Constant #{class_name} already defined in scope of #{obj_scope}!" if obj_scope.const_defined?(class_name)
      # create a new class from given name:
      # line_item:
      # class LineItem < ActiveResource::Base
      klass = obj_scope.const_set(class_name, Class.new(ActiveResource::Base))
      klass.class_eval do
        self.extend(ClassMethods)
        self.send(:include, InstanceMethods) # include is private
      end
      klass.format = :json # bug in AR must be set here
    end
  end

  module ClassMethods
    
    # Define the connection to be used when talking to a salesking server
    def set_connection(opts)
      self.site     = opts[:site]
      self.user     = opts[:user]
      self.password = opts[:password]
      self.format   = opts[:format].to_sym
    end
  end
  
  module InstanceMethods
    # hook before init in activeresource base because json comes in nested:
    # {client={data}
    def initialize(attributes = {})
      attr = attributes[self.class.element_name] || attributes
      super(attr)
    end

    def save; save_with_validation; end
  end
end