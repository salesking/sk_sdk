require 'resources_spec_helper'

unless sk_available?
  puts 'Sorry cannot connect to your SalesKing server, skipping real connections tests. Please check connection settings in spec_helper'
else

describe Invoice do

  context 'in general' do

    before :all do
      @contact =  Contact.new(:type=>'Client', :organisation=>'Invoice API-Tester')
      @contact.save.should be_true
      @doc = Invoice.new()
      @doc.title = 'A Document from the API'
      @doc.contact_id = @contact.id
      @doc.save.should be_true
    end

    after :all do
      delete_test_data(@doc, @contact)
    end

    it 'should find a doc' do
      doc = Invoice.find(@doc.id)
      doc.title.should == @doc.title
    end
  end

  context 'new' do

    before :all do
      @contact =  Contact.new(:type=>'Client', :organisation=>'Invoice API-Tester')
      @contact.save.should be_true
    end
    after :all do
      @contact.destroy
    end

    it 'should create a doc' do
      doc = Invoice.new
      doc.title = 'A Document from the API'
      doc.notes_before = 'Your shiny new invoice [number]'
      doc.notes_after = 'Please pay me'
      doc.contact_id = @contact.id
      doc.save.should be_true
      doc.errors.should be_empty
      doc.new?.should be_false
      doc.notes_before.should == 'Your shiny new invoice [number]'
      doc.destroy
    end

    it 'should create a doc with default before after texts' do
      doc = Invoice.new
      doc.title = 'A Document from the API'
      doc.contact_id = @contact.id
      doc.save
      doc.errors.should be_empty
      doc.new?.should be_false
      doc.notes_before.should_not be_empty
      doc.destroy
    end

    it 'should fail create a doc without unique number' do
      # if a test failed this invoice might still be present so try to delete
      kick_existing(Invoice, '001')
      doc = Invoice.new(:number=>'001')
      doc.save.should == true
      doc2 = Invoice.new(:number=>'001')
      doc2.save.should == false
      doc2.errors.count.should == 1
      if doc2.errors.respond_to? :on
        doc2.errors.on(:number).should == 'has already been taken'
      else
        doc2.errors[:number].should == ['has already been taken']
      end
      doc.destroy
    end

  end

  describe 'edit' do

    before :all do
      #setup test doc to work with
      # create client
      @contact =  Contact.new(:type=>'Client', :organisation=>'Invoice API-Tester')
      @contact.save.should be_true
      @doc = Invoice.new
      @doc.title = 'A Document from the API'
      @doc.notes_before = 'Your invoice [number]'
      @doc.contact_id = @contact.id
      @doc.save.should be_true
    end

    after :all do
      delete_test_data(@doc, @contact)
    end

    it 'should edit a doc' do
      old_lock_version = @doc.lock_version
      @doc.notes_before.should == 'Your invoice [number]'
      @doc.notes_before = 'You will recieve the amout of:'
      @doc.notes_after = 'Payment made to you bank Account'
      @doc.title = 'Changed doc title'

      @doc.save.should be_true
      @doc.lock_version.should > old_lock_version # because save returns the data
      @doc.notes_before.should == 'You will recieve the amout of:'
    end

    it 'should fail edit with wrong number' do
      kick_existing(Invoice, '002')
      doc1 = Invoice.new(:number=>'002')
      doc1.save.should == true
      @doc.number = '002'
      @doc.save.should == false
      @doc.errors.count.should == 1
      if @doc.errors.respond_to? :on # TODO kick with AR 2.3
        @doc.errors.on(:number).should == 'has already been taken'
      else
        @doc.errors[:number].should == ['has already been taken']
      end
      doc1.destroy
    end
  end

  describe 'with line items' do

    before :all do
      @contact =  Contact.new(:type=>'Client', :organisation=>'Credit Note API-Tester')
      @contact.save.should be_true
      #setup test doc to work with
      @doc = Invoice.new(:contact_id => @contact.id,
                          :line_items => [{ :position=>1, :description => 'Pork Chops',
                                             :quantity => 12, :price_single =>'10.00' }] )
      @doc.save.should be_true
    end

    after :all do
      delete_test_data(@doc, @contact)
    end

    it 'should create a line item' do
      @doc.line_items.length.should == 1
      @doc.line_items.first.description.should == 'Pork Chops'
      @doc.gross_total.should == 120.0
    end

    it 'should edit line item' do
      @doc.line_items[0].description = 'Egg Sandwich'
      @doc.save
      @doc.line_items.length.should == 1
      @doc.line_items.first.description.should == 'Egg Sandwich'
    end

    it 'should add line item' do
      item = LineItem.new( {  :position=>2, :description => 'Goat-Pie', :price_single => 10, :quantity=>10} )
      product = Product.new(:name=>'Eis am Stiel', :price => 1.50, :tax=>19, :description => 'Mmmhh lecker Eis')
      product.save.should be_true
      item1 = LineItem.new( { :position=>3, :use_product => 1, :product_id=> product.id, :quantity => 10 } )
      @doc.line_items << item
      @doc.line_items << item1
      @doc.save
      @doc.line_items.length.should == 3
      @doc.net_total.should == 235.0
      @doc.gross_total.should == 237.85
    end

  end

  describe 'with items of different type' do
    before :all do
      @contact = Contact.new(:type=>'Client', :organisation=>'Credit Note API-Tester')
      @contact.save.should be_true
      @doc = Invoice.new(:contact_id => @contact.id)
    end

    after :all do
      #delete_test_data(@doc, @contact)
    end

    it 'should create items with price of 0' do
      # :quantity => 1,  is default
      @doc.items = [
        { :position=>1, :name => 'Pork Chops', :price_single =>'0.00', :type=>'LineItem' },
        { :position=>2, :name => 'Pork Chops', :price_single =>'0,0', :type=>'LineItem' },
        { :position=>3, :name => 'Pork Chops',  :price_single =>'0', :type=>'LineItem' },
        { :position=>4, :name => 'Pork Chops',  :price_single =>0, :type=>'LineItem' },
        { :position=>5, :name => 'Pork Chops',  :price_single =>0.0, :type=>'LineItem' },
      ]
      @doc.save.should be_true
      @doc.items.length.should == 5
      @doc.gross_total.should == 0.0
    end

    it 'should create items from array' do
      @doc.items = [
        { :position=>1, :name => 'Pork Chops', :quantity => 12, :price_single =>'10.00', :type=>'LineItem' },
        { :position=>2, :name => 'Pork Sub Total', :type=>'SubTotalItem' },
        { :position=>2, :name => 'Yummi Beef', :type=>'DividerItem' },
        { :position=>3, :name => 'Beef Jerky', :description=> 'Jaw Breaker',:quantity => 1, :price_single =>'10.00', :type=>'LineItem' }
      ]
      @doc.save.should be_true
      @doc.items.length.should == 4
      @doc.gross_total.should == 130.0
    end

    it 'should create items from array with prefixed hashes' do
      # setting type eg: :type=>'LineItem' is optional
      @doc.items = [
        { :line_item => { :position=>1, :name => 'Pork Chops', :quantity => 12, :price_single =>'10.00', :type=>'LineItem' }},
        { :sub_total_item => { :position=>2, :name => 'Pork Sub Total' }},
        { :divider_item => { :position=>2, :name => 'Yummi Beef', :type=>'DividerItem' }},
        { :line_item => { :position=>3, :name => 'Beef Jerky', :description=> 'Jaw Breaker',:quantity => 1, :price_single =>'10.00' }}
      ]
      @doc.save.should be_true
      @doc.items.length.should == 4
      @doc.gross_total.should == 130.0
    end
  end

  describe 'with items and line_items' do
    before :all do
      @contact = Contact.new(:type=>'Client', :organisation=>'Credit Note API-Tester')
      @contact.save.should be_true
      @doc = Invoice.new(:contact_id => @contact.id)
    end

    after :all do
      delete_test_data(@doc, @contact)
    end

    it 'should prefer line_items over items when both are present' do
      @doc.items = [LineItem.new( :position=>12, :name => 'dropped', :quantity => 1, :price_single =>1, :type=>'LineItem' )]
      @doc.line_items = [LineItem.new( :position=>12, :name => 'added', :quantity => 1, :price_single =>10, :type=>'LineItem' )]
      @doc.save.should be_true
      @doc.items.length.should == 1
      @doc.gross_total.should == 10.0
    end

    it 'should manually remove line_items so items are used on update' do
      # first save so AR loads both(items/line_items) from response
      @doc.items = [ { :position=>1, :name => 'Pork Chops', :quantity => 1, :price_single =>'10.00', :type=>'LineItem' }]
      @doc.save.should be_true
      @doc.gross_total.should == 10.0
      # edit
      @doc.items << LineItem.new( :position=>2, :name => 'Puppy Seeds', :quantity => 1, :price_single =>1, :type=>'LineItem' )
      @doc.line_items = nil # <= IMPORTANT  part

      @doc.save.should be_true
      @doc.items.length.should == 2
      @doc.gross_total.should == 11.0
    end

  end
end

end
