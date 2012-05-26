require 'resources_spec_helper'

unless sk_available?
  puts "Sorry cannot connect to your SalesKing server, skipping real connections tests. Please check connection settings in spec_helper"
else

  describe Client, "with real connection" do

    before :all do
      @client = Client.new(:organisation=>'from testing API2')
      @client.save
    end

    after :all do
      #delete test client
      @client.destroy
      lambda {
        client = Client.find(@client.id)
      }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should save" do
      c = Client.new :organisation=>"Rack'n Roll"
      c.save.should be_true
      c.id.should_not be_empty
      c.number.should_not be_empty
    end

    it "should fail create a client" do
      client = Client.new(:organisation=>'from testing API2')
      client.bank_iban = 'safasf'
      client.save.should == false
      client.errors.count.should == 1
      client.errors.full_messages.should ==  ["Bank iban is invalid"]
    end

    it "should find a single client" do
      client = Client.find(@client.id)
      client.organisation.should == @client.organisation
    end

    it "should find clients" do
      clients = Client.find(:all)
      clients.should_not be_empty
    end
  end


  describe Client, "with addresses" do

    before :all do
      #setup test client to work with
      @client = Client.new(:organisation=>'Second from testing API2',
                            :addresses => [{ :zip => '50374', :city => 'Cologne' }] )

      @client.save
    end

    after :all do
      @client.destroy
      lambda {
        client = Client.find(@client.id)
      }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should create an address" do
      @client.addresses.length.should == 1
      @client.addresses.first.zip.should == '50374'
    end

    it "should edit an address" do
      @client.addresses.length.should == 1
     # puts @client.addresses.inspect
      @client.addresses[0].zip = '40001'
      @client.save
      @client.addresses.length.should == 1
      @client.addresses.first.zip.should == '40001'
    end

    it "should add an address" do
      cnt_before = @client.addresses.length
      adr = Address.new( { :zip => '37700', :city => 'Cologne' } )
      @client.addresses << adr
      @client.save
      @client.addresses.length.should == cnt_before+1
    end

    it "should destroy an address" do
      cnt_before = @client.addresses.length
      @client.addresses.last._destroy = 1
      @client.save
      @client.reload
      @client.addresses.length.should == cnt_before-1
    end
  end


end