require 'spec/spec_helper'

describe SK::SDK::ArCli, "make new class" do

  before :all do
    SK::SDK::ArCli.make(:client)
    Client.set_connection( CONNECTION )
  end

  it "should create class" do
    c = Client.new
    c.first_name = 'herbert' # implicit setter
    c.first_name.should == 'herbert' # implicit getter
    c1 = Client.new
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
  end

  it "should raise error on second create" do
    lambda{
      SK::SDK::ArCli.make(:client)
    }.should raise_error(RuntimeError, "Constant Client already defined in scope of Object!")
  end

  it "should allow create a second class in different scope" do
    lambda{
      SK::SDK::ArCli.make(:client, SK::API)
      c = SK::API::Client.new
      c.id
    }.should_not raise_error(RuntimeError)
  end
end

if sk_available?
  describe SK::SDK::ArCli, "with real connection" do

    before :all do
      SK::SDK::ArCli.make(:client) unless Object.const_defined?('Client')
      Client.set_connection( CONNECTION )
    end

    it "should save" do
      c = Client.new :organisation=>"Rack'n Roll"
      c.save.should be_true
      c.id.should_not be_empty
      c.number.should_not be_empty
    end
  end
else
  puts "Sorry your local SalesKing server ain't running, skipping real connections tests"
end
