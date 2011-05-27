CONNECTION = {
    :site => "http://demo.salesking.local:3000/api/",
    :password => "demo",
    :user => "demo@salesking.eu"
} unless defined?(CONNECTION)

# create all classes and set their connection
%w[Client Address CreditNote Invoice Product LineItem].each do |model|
  eval "class #{model} < SK::SDK::Base;end" unless Object.const_defined?(model)
end
SK::SDK::Base.set_connection CONNECTION

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

