require 'spec/spec_helper'

describe SK::SDK::Oauth, "in general" do

  before :each do
    #setup test oAuth-data to work with
    load_settings
  end

  it "should create a new instance" do
    lambda{ SK::SDK::Oauth.new(@set)}.should_not raise_error
  end

  it "should get salesking url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.sk_url.should == "http://alki.horsts-lokal.local"
  end

  it "should get auth_dialog url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.auth_dialog.should include "http://alki.horsts-lokal.local/oauth/authorize?"
    a.auth_dialog.should include @set['app_id']
    a.auth_dialog.should include CGI::escape @set['app_redirect_url']
    a.auth_dialog.should include CGI::escape @set['app_scope']
  end

  it "should get sk_canvas_url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    a.sk_canvas_url.should == "http://alki.horsts-lokal.local/app/canvas-page"
  end

  it "should get token_url" do
    a = SK::SDK::Oauth.new(@set)
    a.sub_domain = 'alki'
    url = a.token_url('some-code')
    url.should include @set['app_id']
    url.should include @set['app_secret']
    url.should include CGI::escape @set['app_redirect_url']
  end

end