require 'resources_spec_helper'

unless sk_available?
  puts "Sorry cannot connect to your SalesKing server, skipping real connections tests. Please check connection settings in spec_helper"
else

describe Payment do

  before :all do
    @contact = Contact.new(:type=>'Client', :organisation=>'Payment API-Tester')
    @contact.save.should be true
    @doc = Invoice.new
    @doc.title = 'A Document from the API for payment testing'
    @doc.contact_id = @contact.id
    @doc.save.should be true
  end

  after :all do
    payments = Payment.instantiate_collection(@doc.get(:payments))
    payments.each { |p| p.destroy }
    @doc.status = 'draft'
    @doc.save
    @contact.destroy
  end

  describe "POST request for invoice" do
    it "should create" do
      p = Payment.new :amount => 10

      # damn i hate active_resource
      @doc.post(:payments, {}, p.encode)
      payments_json = @doc.get(:payments)
      payments = Payment.send(:instantiate_collection, payments_json)

      payments.first.amount.should == 10
    end

    it "should create with method date external_ref" do
      p = Payment.new :amount => 11,
                      :payment_method => "bank_transfer",
                      :date=> Date.today,
                      :external_ref => 'from sdk-test'

      # damn i hate active_resource
      @doc.post(:payments, {}, p.encode)
      payments = Payment.send(:instantiate_collection, @doc.get(:payments))
      payment = payments.detect{|p| p.amount == 11 }
      payment.external_ref.should == 'from sdk-test'
      payment.date.should == Date.today.strftime("%Y-%m-%d")
      # method is defined on Object .. TODO rename it in SK
      payment.attributes['payment_method'].should == 'bank_transfer'
    end

    it "should close related invoice" do
      p = Payment.new :amount => 10

      # damn i hate active_resource
      @doc.post(:payments, {:new_doc_status=>'closed'}, p.encode)
      doc = Invoice.find @doc.id
      doc.status.should == 'closed'
      doc.number.should be
    end

  end

  describe "direct POST create" do
    it "should create" do
                                      # relation MUST be set
      p = Payment.new :amount => 12.34, :related_object_id=>@doc.id
      p.save.should be true

      payments = Payment.send( :instantiate_collection, @doc.get(:payments))
      payments.map(&:amount).should include 12.34
    end
  end


end

end
