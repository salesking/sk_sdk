require 'resources_spec_helper'

unless sk_available?
  puts "Sorry cannot connect to your SalesKing server, skipping real connections tests. Please check connection settings in spec_helper"
else

  describe CreditNote, "in general" do

    before :all do
      #setup test doc to work with
      # create client
      @client = Client.new(:organisation=>'Credit Note API-Tester')
      @client.save.should be_true
      @doc = CreditNote.new()
      @doc.title = 'A Document from the API'
      @doc.client_id = @client.id
      @doc.save.should be_true
    end

    after :all do
      delete_test_data @doc, @client
    end

    it "should create a doc and use default before after text" do
      @doc.errors.should be_empty
      @doc.notes_before.should_not be_empty
      @doc.new?.should be_false
    end

    it "should fail create a doc without unique number" do
      kick_existing(CreditNote, '001')
      doc = CreditNote.new(:number=>'001')
      doc.save.should == true
      doc2 = CreditNote.new(:number=>'001')
      doc2.save.should == false
      doc2.errors.count.should == 1
      if doc2.errors.respond_to? :on # TODO kick with AR 2.3
        doc2.errors.on(:number).should == "has already been taken"
      else
        doc2.errors[:number].should == ["has already been taken"]
      end
      doc.destroy
    end

    it "should find a doc" do
      doc = CreditNote.find(@doc.id)
      doc.title.should == @doc.title
    end

    it "should edit a doc" do
      old_lock_version = @doc.lock_version
      @doc.notes_before = 'You will recieve the amout of:'
      @doc.notes_before = 'Payment made to you bank Account'
      @doc.title = 'Changed doc title'

      @doc.save.should be_true
      @doc.lock_version.should > old_lock_version # because save returns the data
    end

    it "should fail edit with wrong number" do
      kick_existing(CreditNote, '002')
      doc1 = CreditNote.new(:number=>'002')
      doc1.save.should == true
      @doc.number = '002'
      @doc.save.should == false
      @doc.errors.count.should == 1
      if @doc.errors.respond_to? :on # TODO kick with AR 2.3
        @doc.errors.on(:number).should == "has already been taken"
      else
        @doc.errors[:number].should == ["has already been taken"]
      end
      doc1.destroy
    end
  end

  describe CreditNote, "with line items" do

    before :all do
      @client = Client.new(:organisation=>'Credit Note API-Tester')
      @client.save.should be_true
      #setup test doc to work with
      @doc = CreditNote.new :client_id => @client.id,
                            :line_items =>[{ :position=>1, :description => 'Pork Chops',
                                              :quantity => 12, :price_single =>'10.00'}]
      @doc.save.should be_true
    end

    after :all do
      delete_test_data @doc, @client
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
      item = LineItem.new :position=>2, :description => 'Goat-Pie',
                          :price_single => 10, :quantity=>10
      @doc.line_items << item
      @doc.save
      @doc.line_items.length.should == 2
      @doc.price_total.should == 220.0
  #    @doc.line_items[0].zip = '40001'
  #    @doc.line_items.[1].zip.should == '40001'
    end
  end

  describe CreditNote, "with status change" do

    before :all do
      @doc = CreditNote.new :title => 'Status test'
    end

    after :all do
  #    @doc.destroy
#      lambda {
#        doc = CreditNote.find(@doc.id)
#      }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should update from draft to open and set number with date" do
      @doc.save.should be_true
      @doc.status.should == 'draft'

      @doc.status = 'open'
      @doc.save
      @doc.status.should == 'open'
      @doc.number.should_not be_empty
      @doc.date.to_s.should_not be_empty
      # make draft to be deleted
      @doc.status = 'draft'
      @doc.save
      @doc.destroy
    end

  end
end