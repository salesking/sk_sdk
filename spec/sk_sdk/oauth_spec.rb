require 'spec_helper'

describe SK::SDK::Oauth, "in general" do

  before :each do
    #setup test oAuth-data to work with
    @set = oauth_settings
  end

  it "should create a new instance" do
    lambda{ SK::SDK::Oauth.new(@set)}.should_not raise_error
  end

  it "should get salesking url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.sk_url.should == "http://alki.horsts-lokal.local"
  end

  it "should get salesking api url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.sk_api_url.should == "http://alki.horsts-lokal.local/api"
  end

  it "should get auth_dialog url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.auth_dialog.should include "http://alki.horsts-lokal.local/oauth/authorize?"
    a.auth_dialog.should include @set['id']
    a.auth_dialog.should include CGI::escape @set['redirect_url']
    a.auth_dialog.should include CGI::escape @set['scope']
  end

  it "should get sk_canvas_url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.sk_canvas_url.should == "http://alki.horsts-lokal.local/app/canvas-page"
  end

  it "has token_url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.token_url.should == "http://alki.horsts-lokal.local/oauth/token"
  end

  it "has token_params" do
    a = SK::SDK::Oauth.new(@set)
    res = a.token_params('123')
    res[:code].should == '123'
    res[:client_id].should == @set['id']
    res[:grant_type].should == 'authorization_code'
    res[:redirect_uri].should == CGI::escape(@set['redirect_url'])
  end

end