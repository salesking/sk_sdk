require 'spec_helper'

describe SK::SDK::Sync::Field do

  it "should init with array fields" do
    flds = []
    field_map.each do |fld|
      flds << SK::SDK::Sync::Field.new(fld)
    end
    flds.length.should == field_map.length
    flds.first.should be_a_kind_of SK::SDK::Sync::Field
  end

  it "should set names fields" do
    opts = field_map.first
    fld = SK::SDK::Sync::Field.new(opts)
    fld.l_name.should == opts[0]
    fld.r_name.should == opts[1]
  end

  it "should set transition methods" do
    opts = field_map.last
    fld = SK::SDK::Sync::Field.new(opts)
    fld.l_trans.should == opts[2]
    fld.r_trans.should == opts[3]
  end



  def field_map
    [
      [:firstname, :first_name],
      [:street, :address1],
      [:postcode, :zip],
      [:city, :city],
      [:gender, :gender, :'TransMethods.set_local_gender', :'TransMethods.set_remote_gender']
    ]

  end

end