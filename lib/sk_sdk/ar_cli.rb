require 'rubygems'
require 'sk_sdk'
require 'sk_sdk/base'

module SK::SDK
  class ArCli
    # TODO deprecated
    # Create a class for a given name
    #
    # === Example
    #
    #  SK::SDK::ArCli.make(:client)
    #  c = Client.new
    #
    #  SK::SDK::ArCli.make(:credit_note, SK::API)
    #  i = SK::API::CreditNote.new
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
      # :line_item  => # class LineItem < ActiveResource::Base
      obj_scope.const_set( class_name, Class.new(SK::SDK::Base) )
    end
  end
end