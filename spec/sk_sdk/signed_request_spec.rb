require 'spec/spec_helper'

describe SK::SDK::SignedRequest, "in general" do

  before :each do
    #setup test oAuth-data to work with
    load_settings
    # fake request
    @param_hash = {'hello' =>'coder', 'algorithm' => 'HMAC-SHA256'}
    @param = SK::SDK::SignedRequest.signed_param( ActiveSupport::JSON.encode(@param_hash), @set['secret'] )
  end

  it "should decode payload" do
    a = SK::SDK::SignedRequest.new(@param, @set['secret'])
    a.data.should_not be_nil
    a.payload.should_not be_nil
    a.sign.should_not be_nil
    a.should be_valid
  end

end