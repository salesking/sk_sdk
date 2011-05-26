CONNECTION = {
    :site => "http://demo.salesking.local:3000/api/",
    :password => "demo",
    :user => "demo@salesking.eu"
} unless defined?(CONNECTION)

# create all classes and set their connection
# instead of
# SK::SDK::ArCli.make(:client) unless Object.const_defined?('Client')
# Client.set_connection( CONNECTION )
[:client, :address, :credit_note, :line_item, :invoice, :product].each do |name|
  class_name = "#{name}".camelize
  SK::SDK::ArCli.make(class_name) unless Object.const_defined?(class_name)
  class_name.constantize.set_connection( CONNECTION )
end


# check if a SalesKing instance is available by calling /users/current.json
def sk_available?
  SK::SDK::ArCli.make(:user) unless Object.const_defined?('User')
  User.set_connection( CONNECTION )
  begin
    User.get(:current)
  rescue Errno::ECONNREFUSED #ActiveResource::ResourceNotFound => e
    return false
  end

end


def delete_test_data(doc, client)
  doc.destroy
  client.destroy
  lambda {
    doc = Invoice.find(doc.id)
  }.should raise_error(ActiveResource::ResourceNotFound)
  lambda {
    client = Client.find(client.id)
  }.should raise_error(ActiveResource::ResourceNotFound)
end

