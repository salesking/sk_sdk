require 'spec_helper'
# create all classes and set their connection
%w[Client Address CreditNote Invoice Product LineItem User Payment Email].each do |model|
  eval "class #{model} < SK::SDK::Base;end" unless Object.const_defined?(model)
end
SK::SDK::Base.set_connection basic_auth_settings
# check if a SalesKing instance is available by calling /users/current.json
def sk_available?
  begin
    User.get(:current)
  rescue
    return false
  end
end

# Params
# obj<Class>:: class name
# number<String>:: the document number the kick
def kick_existing(obj, number)
  if existing = obj.find(:first, :params =>{ :filter=>{ :number => number } })
    existing.destroy
  end
end

def delete_test_data(doc, client)
  if doc.status !='draft'
    doc.status ='draft'
    doc.save
  end
  #doc.destroy
  client.destroy
end

