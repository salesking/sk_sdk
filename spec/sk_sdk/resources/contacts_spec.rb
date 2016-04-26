require 'resources_spec_helper'

unless sk_available?
  puts "Sorry cannot connect to your SalesKing server, skipping real connections tests. Please check connection settings in spec_helper"
else

  describe Contact, "with real connection" do

    before :all do
      @contact = Contact.new(:organisation=>'from testing API2', :type => 'Lead')
      @contact.save
    end

    after :all do
      #delete test contact
      @contact.destroy
      lambda {
        contact = Contact.find(@contact.id)
      }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should save" do
      c = Contact.new :organisation=>"Rack'n Roll", :type => 'Client'
      c.save.should be true
      c.id.should_not be_empty
      c.number.should_not be_empty
      c.destroy
    end

    it "should fail create a contact" do
      contact = Contact.new(:organisation=>'from testing API2', :type => 'Client')
      contact.bank_iban = 'safasf'
      contact.save.should == false
      contact.errors.count.should == 1
      contact.errors.full_messages.should ==  ["Bank iban is invalid"]
    end

    it "should find a single contact" do
      contact = Contact.find(@contact.id)
      contact.organisation.should == @contact.organisation
    end

    it "should find contacts" do
      contacts = Contact.find(:all)
      contacts.length.should > 0
    end
  end


  describe Contact, "with addresses" do

    before :all do
      #setup test contact to work with
      @contact = Contact.new(:organisation=>'Second from testing API2',
                             :type => 'Client',
                            :addresses => [{ :zip => '50374', :city => 'Cologne' }] )

      @contact.save
    end

    after :all do
      @contact.destroy
      lambda {
        contact = Contact.find(@contact.id)
      }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should create an address" do
      @contact.addresses.length.should == 1
      @contact.addresses.first.zip.should == '50374'
    end

    it "should edit an address" do
      @contact.addresses.length.should == 1
     # puts @contact.addresses.inspect
      @contact.addresses[0].zip = '40001'
      @contact.save
      @contact.addresses.length.should == 1
      @contact.addresses.first.zip.should == '40001'
    end

    it "should add an address" do
      cnt_before = @contact.addresses.length
      adr = Address.new( { :zip => '37700', :city => 'Cologne' } )
      @contact.addresses << adr
      @contact.save
      @contact.addresses.length.should == cnt_before+1
    end

    it "should destroy an address" do
      cnt_before = @contact.addresses.length
      @contact.addresses.last._destroy = 1
      @contact.save
      @contact.reload
      @contact.addresses.length.should == cnt_before-1
    end
  end
end