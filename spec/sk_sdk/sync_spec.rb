require 'spec/spec_helper'

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

  it "should not be outdated" do
    @sync.outdated?.should be_false # both objects are empty
  end

  it "should find outdated fields" do
    @l_obj.firstname = 'theo'
    @sync.outdated?.should be_true
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
    @r_obj.first_name.should == @l_obj.firstname
    @sync.log.length.should == 1
  end

  def field_map
#    [
#      [:firstname, :first_name, :set_local_name, :set_remote_name],
#    ]
    [
      {:firstname => :first_name},
      {:street => :address1},
      {:postcode => :zip},
      {:city => :city},
      {:gender => :gender, :trans => { "TransMethods.set_local_gender" => :'TransMethods.set_remote_gender'}
      }
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