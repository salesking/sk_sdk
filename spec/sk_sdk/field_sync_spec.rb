require 'spec/spec_helper'

describe SK::SDK::FieldSync do

  before :each do
    @l_obj = LocalContact.new
    @r_obj = RemoteContact.new()
    @map = SK::SDK::FieldSync.new(@l_obj, @r_obj, map_hash)
  end

  it "should create a mapping" do
    @map.outdated?.should be_false # both objects are empty
  end

  it "should find outdated fields" do
    @l_obj.firstname = 'theo'
    @map.outdated?.should be_true
    @map.outdated.first[:l].should == :firstname
  end

  it "should update outdated remote fields" do
    @l_obj.firstname = 'theo'
    @map.update_remote_outdated
    @r_obj.first_name.should == @l_obj.firstname
    # test logging
   @map.log.should_not be_empty
  end

  it "should update outdated local fields" do
    @r_obj.first_name = 'Heinz'
    @map.update_local_outdated
    @r_obj.first_name.should == @l_obj.firstname
    @map.log.length.should == 1
  end
#  it "should update outdated local fields" do
#    @r_obj.first_name = 'Heinz'
#    @map.outdated?
#    @map.update_local_outdated
#    @r_obj.first_name.should == @l_obj.firstname
#  end

  def map_hash
    [
      {:l => :firstname,  :r => :first_name},
      {:l => :street,     :r => :address1},
      {:l => :postcode,   :r => :zip},
      {:l => :city,       :r => :city},
      {:l => :gender,     :r => :gender, :trans => { :obj=>'TransferFunctions',
                                                     :l => 'set_local_gender',
                                                     :r => 'set_remote_gender'}
      }
#      {:firstname => :first_name},
#      {:street => :address1},
#      {:postcode => :zip},
#      {:city => :city},
#      {:gender => :gender, :trans => { :obj=>'TransferFunctions',
#                                       :set_local_gender =>:set_remote_gender}
#      }
    ]
  end

end

class RemoteContact
  attr_accessor :first_name, :address1, :zip, :city, :gender
end
class LocalContact
  attr_accessor :firstname, :street, :postcode, :city, :gender
end

class TransferFunctions
  def self.set_local_gender(remote_val)
    return 'male' if remote_val == 'm'
    return 'female' if remote_val == 'f'
  end
  def self.set_remote_gender(local_val)
    return 'm' if local_val == 'male'
    return 'f' if local_val == 'female'
  end
end