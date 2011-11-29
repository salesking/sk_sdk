require 'spec_helper'
require 'resources_spec_helper'

class Client < SK::SDK::Base;end
# create objects in King namespace
module KingTester; end
%w[Invoice Product].each do |model|
  eval "class KingTester::#{model} < SK::SDK::Base;end"
end

describe SK::SDK::Base, "make new class" do

  it "should create class" do
    c = Client.new
    c.first_name = 'herbert' # implicit setter
    c.first_name.should == 'herbert' # implicit getter
  end

  it "should set api url" do
    opts = {:site => 'https://my.salesking.eu', :token=>'123'}
    result = 'https://my.salesking.eu/api'

    SK::SDK::Base.set_connection(opts)
    SK::SDK::Base.site.to_s.should == result

    opts[:site] = 'https://my.salesking.eu/'
    SK::SDK::Base.set_connection(opts)
    SK::SDK::Base.site.to_s.should == result

    opts[:site] ='https://my.salesking.eu/api'
    SK::SDK::Base.set_connection(opts)
    SK::SDK::Base.site.to_s.should == result

    opts[:site] = 'https://my.salesking.eu/api/'
    SK::SDK::Base.set_connection(opts)
    SK::SDK::Base.site.to_s.should == result
  end

  it "should have properties as attributes" do
    c = Client.new :some_field => ''
    c.attributes.should == {"some_field"=>""}
  end

  it "should create save method" do
    c = Client.new 
    c.respond_to?(:save).should be_true
  end

  it "should have new_record?" do
    c = Client.new
    c.new_record?.should be_true
    i = KingTester::Invoice.new
    i.new_record?.should be_true
    p = KingTester::Product.new
    p.new_record?.should be_true
  end

  it "should allow multiple parameters in initializer" do
    expect {
      if ActiveResource::VERSION::MAJOR == 3
        Client.new({ :first_name => 'herbert' }, true)
      else
        Client.new({ :first_name => 'herbert' })
      end
    }.should_not raise_error(ArgumentError)
  end

end
