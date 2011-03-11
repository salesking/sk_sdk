require 'cgi'
require 'curb'
module SK::SDK
  # Authenticate your SalesKing App using oAuth2. This class holds common methods
  class Oauth

    attr_reader :app_id, :app_secret, :app_redirect_url
    attr_accessor :sub_domain

    def initialize(opts)
      @app_id           = opts['app_id']
      @app_secret       = opts['app_secret']
      @app_scope        = opts['app_scope']
      @app_redirect_url = opts['app_redirect_url']
      @app_canvas_slug  = opts['app_canvas_slug']
      @sk_url           = opts['sk_url']

    end

    # URL showing the auth dialog to the user
    #
    # === Returns
    # <String>:: Url with parameter
    def auth_dialog
#      params = { :client_id   => @app_id,
#                 :redirect_uri=> @app_redirect_url,
#                 :scope       => @app_scope }
      "#{sk_url}/oauth/authorize?client_id=#{@app_id}&redirect_uri=#{CGI::escape @app_redirect_url}&scope=#{CGI::escape @app_scope}"
    end

    # return the app's canvas url: the url inside SalesKing
    def sk_canvas_url
      "#{sk_url}/app/#{@app_canvas_slug}"
    end

    # URL to get the access_token, used in the second step after you have
    # requested the authorization and gotten a code
    # === Parameter
    # code<String>:: code received after auth
    # === Returns
    # <String>:: Url with parameter
    def token_url(code)
#      params = { :client_id     => @app_id,
#                 :client_secret => @app_secret,
#                 :redirect_uri  => @app_redirect_url,
#                 :code          => code }
      "#{sk_url}/oauth/access_token?code=#{code}&client_id=#{@app_id}&client_secret=#{@app_secret}&redirect_uri=#{CGI::escape @app_redirect_url }"
    end

    # Makes a GET request to the access_token endpoint in SK and receives the
    # oauth/access token
    def get_token(code)
      c = Curl::Easy.perform( token_url( code ) )
      # grab token from response body, containing json string
      ActiveSupport::JSON.decode(c.body_str)
    end

    # Each company has it's own subdomain so the url must be dynamic.
    # This is achieved by replacing the * with the subdomain from the session
    # === Returns
    # <String>:: url
    def sk_url
      @sk_url.gsub('*', sub_domain)
    end

  end
end