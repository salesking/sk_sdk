require 'spec/spec_helper'

describe SK::SDK::ArClient, "make new class" do

  before :all do
    SK::SDK::ArClient.make(:client)
    Client.set_connection( CONNECTION )
  end

  it "should create class from schema" do
    # hash from json schema
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
      SK::SDK::ArClient.make(:client)
    }.should raise_error(RuntimeError, "Constant Client already defined in scope of Object!")
  end

  it "should allow create a second class in different scope" do
    lambda{
      SK::SDK::ArClient.make(:client, SK::API)
      c = SK::API::Client.new
      c.id
    }.should_not raise_error(RuntimeError)
  end
end
