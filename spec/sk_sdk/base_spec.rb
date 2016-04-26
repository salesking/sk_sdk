require 'spec_helper'
require 'resources_spec_helper'

class Contact < SK::SDK::Base;end
# create objects in King namespace
module KingTester; end
%w[Invoice Product].each do |model|
  eval "class KingTester::#{model} < SK::SDK::Base;end"
end

describe SK::SDK::Base, "make new class" do

  it "should create class" do
    c = Contact.new
    c.first_name = 'herbert' # implicit setter
    c.first_name.should == 'herbert' # implicit getter
  end

  it "should set api url" do
    result = 'https://my.salesking.eu/api'

    SK::SDK::Base.send(:site_api_url, 'https://my.salesking.eu').should == result
    SK::SDK::Base.send(:site_api_url, 'https://my.salesking.eu/api').should == result

  end

  it "should have properties as attributes" do
    c = Contact.new :some_field => ''
    c.attributes.should == {"some_field"=>""}
  end

  it "should create save method" do
    c = Contact.new
    c.respond_to?(:save).should be true
  end

  it "should have new_record?" do
    c = Contact.new
    c.new_record?.should be true
    i = KingTester::Invoice.new
    i.new_record?.should be true
    p = KingTester::Product.new
    p.new_record?.should be true
  end

  it "should allow multiple parameters in initializer" do
    expect {
      if ActiveResource::VERSION::MAJOR == 3 && ActiveResource::VERSION::MINOR > 0
        Contact.new({ :first_name => 'herbert' }, true)
      else
        Contact.new({ :first_name => 'herbert' })
      end
    }.to_not raise_error(ArgumentError)
  end

end
