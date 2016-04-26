require 'spec_helper'

describe SK::SDK::Sync do

  before :each do
    @l_obj = LocalContact.new
    @r_obj = RemoteContact.new
    @sync = SK::SDK::Sync.new(@l_obj, @r_obj, field_map)
  end

  it "should create fields" do
    @sync.fields.length.should == field_map.length
    @sync.fields.first.should be_a_kind_of SK::SDK::Sync::Field
  end

  it "should raise error with wrong side" do
    lambda{
      @sync.update(:x)
    }.should raise_error(ArgumentError)
  end

  it "should not be outdated" do
    @sync.outdated?.should be false # both objects are empty
  end

  it "should find outdated fields" do
    @l_obj.firstname = 'theo'
    @sync.outdated?.should be true
    @sync.outdated.first.should == @sync.field(:firstname)
  end

  it "should update outdated remote fields" do
    @l_obj.firstname = 'theo'
    @sync.update_remote_outdated

    @r_obj.first_name.should == @l_obj.firstname
    @sync.log.should_not be_empty
  end

  it "should update outdated local fields" do
    @r_obj.first_name = 'Heinz'
    @sync.update_local_outdated
    @l_obj.firstname.should == @r_obj.first_name
    @sync.log.length.should == 1
  end

  it "should update outdated remote fields with transition" do
    @l_obj.gender = 'female'
    @sync.update_remote_outdated

    @r_obj.gender.should == "f"
    @sync.log.should_not be_empty
  end

  it "should update outdated local fields with transition" do
    @r_obj.gender = 'm'
    @sync.update_local_outdated
    @l_obj.gender.should == 'male'
    @sync.log.length.should == 1
  end

  it "should update all remote fields" do
    @l_obj.firstname = 'John'
    @l_obj.street = 'Sync Ave 666'
    @l_obj.postcode = '96969'
    @l_obj.city = 'Wichita'
    @l_obj.gender = 'female'
    @sync.update(:r)

    @r_obj.first_name.should == @l_obj.firstname
    @r_obj.address1.should == @l_obj.street
    @r_obj.zip.should == @l_obj.postcode
    @r_obj.city.should == @l_obj.city
    @r_obj.gender.should == "f"
    @sync.log.should_not be_empty
  end

  it "should update all local fields" do
    @r_obj.gender = 'm'
    @r_obj.first_name = 'John'
    @r_obj.address1 = 'Sync Ave 666'
    @r_obj.zip = '96969'
    @r_obj.city = 'Wichita'
    @sync.update(:l)

    @l_obj.firstname.should == @r_obj.first_name
    @l_obj.street.should == @r_obj.address1
    @l_obj.postcode.should == @r_obj.zip
    @l_obj.city.should == @r_obj.city
    @l_obj.gender.should == 'male'
    @sync.log.length.should == 5
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

################################################################################
# Dummi Classes used in specs
################################################################################
class RemoteContact
  attr_accessor :first_name, :address1, :zip, :city, :gender
end

class LocalContact
  attr_accessor :firstname, :street, :postcode, :city, :gender
end

class TransMethods
  def self.set_local_gender(remote_val)
    return 'male' if remote_val == 'm'
    return 'female' if remote_val == 'f'
  end
  def self.set_remote_gender(local_val)
    return 'm' if local_val == 'male'
    return 'f' if local_val == 'female'
  end
end