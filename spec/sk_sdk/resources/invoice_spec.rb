#require 'spec_helper'
require 'resources_spec_helper'

unless sk_available?
  puts "Sorry cannot connect to your SalesKing server, skipping real connections tests. Please check connection settings in spec_helper"
else

describe Invoice, "in general" do

  before :all do
    @client = Client.new(:organisation=>'Invoice API-Tester')
    @client.save.should be_true
    @doc = Invoice.new()
    @doc.title = 'A Document from the API'
    @doc.client_id = @client.id
    @doc.save.should be_true
  end

  after :all do
    delete_test_data(@doc, @client)
  end

  it "should find a doc" do
    doc = Invoice.find(@doc.id)
    doc.title.should == @doc.title
  end
end

describe Invoice, "a new invoice" do

  before :all do
    @client = Client.new(:organisation=>'Invoice API-Tester')
    @client.save.should be_true
  end
  after :all do
    @client.destroy
  end

  it "should create a doc" do
    doc = Invoice.new
    doc.title = 'A Document from the API'
    doc.notes_before = 'Your shiny new invoice [number]'
    doc.notes_after = 'Please pay me'
    doc.client_id = @client.id
    doc.save.should be_true
    doc.errors.should be_empty
    doc.new?.should be_false
    doc.notes_before.should == 'Your shiny new invoice [number]'
    doc.destroy
  end

  it "should create a doc with default before after texts" do
    doc = Invoice.new
    doc.title = 'A Document from the API'
    doc.client_id = @client.id
    doc.save
    doc.errors.should be_empty
    doc.new?.should be_false
    doc.notes_before.should_not be_empty
    doc.destroy
  end

  it "should fail create a doc without unique number" do
    # if a test failed this invoice might still be present so try to delete
    kick_existing(Invoice, '001')
    doc = Invoice.new(:number=>'001')
    doc.save.should == true
    doc2 = Invoice.new(:number=>'001')
    doc2.save.should == false
    doc2.errors.count.should == 2
    if doc2.errors.respond_to? :on
      doc2.errors.on(:number).should == "has already been taken"
    else
      doc2.errors[:number].should == ["has already been taken"]
    end
    doc.destroy
  end

end

describe Invoice, "Edit an invoice" do

  before :all do
    #setup test doc to work with
    # create client
    @client = Client.new(:organisation=>'Invoice API-Tester')
    @client.save.should be_true
    @doc = Invoice.new
    @doc.title = 'A Document from the API'
    @doc.notes_before = 'Your invoice [number]'
    @doc.client_id = @client.id
    @doc.save.should be_true
  end

  after :all do
    delete_test_data(@doc, @client)
  end

  it "should edit a doc" do
    old_lock_version = @doc.lock_version
    @doc.notes_before.should == 'Your invoice [number]'
    @doc.notes_before = 'You will recieve the amout of:'
    @doc.notes_after = 'Payment made to you bank Account'
    @doc.title = 'Changed doc title'

    @doc.save.should be_true
    @doc.lock_version.should > old_lock_version # because save returns the data
    @doc.notes_before.should == 'You will recieve the amout of:'
  end

  it "should fail edit with wrong number" do
    kick_existing(Invoice, '002')
    doc1 = Invoice.new(:number=>'002')
    doc1.save.should == true
    @doc.number = '002'
    @doc.save.should == false
    @doc.errors.count.should == 2
    if @doc.errors.respond_to? :on # TODO kick with AR 2.3
      @doc.errors.on(:number).should == "has already been taken"
    else
      @doc.errors[:number].should == ["has already been taken"]
    end
    doc1.destroy
  end
end

describe Invoice, "with line items" do

  before :all do
    @client = Client.new(:organisation=>'Credit Note API-Tester')
    @client.save.should be_true
    #setup test doc to work with
    @doc = Invoice.new(:client_id => @client.id,
                        :line_items => [{ :position=>1, :description => 'Pork Chops',
                                           :quantity => 12, :price_single =>'10.00' }] )
    @doc.save.should be_true
  end

  after :all do
    delete_test_data(@doc, @client)
  end

  it "should create a line item" do
    @doc.line_items.length.should == 1
    @doc.line_items.first.description.should == 'Pork Chops'
    @doc.price_total.should == 120.0
  end

  it "should edit line item" do
    @doc.line_items[0].description = 'Egg Sandwich'
    @doc.save
    @doc.line_items.length.should == 1
    @doc.line_items.first.description.should == 'Egg Sandwich'
  end

  it "should add line item" do
    item = LineItem.new( {  :position=>2, :description => 'Goat-Pie', :price_single => 10, :quantity=>10} )
    product = Product.new(:name=>'Eis am Stiel', :price => 1.50, :tax=>19, :description => 'Mmmhh lecker Eis')
    product.save.should be_true
    item1 = LineItem.new( { :position=>3, :use_product => 1, :product_id=> product.id, :quantity => 10 } )
    @doc.line_items << item
    @doc.line_items << item1
    @doc.save
    @doc.line_items.length.should == 3
    @doc.price_total.should == 235.0
  end

end
end
