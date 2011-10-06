require 'cgi'
require 'curb'
require 'sk_sdk'

module SK::SDK
  # Authenticate your SalesKing App using oAuth2. This class provides helpers
  # to create the token & dialog url and to get an access token
  class Oauth

    attr_reader :id, :secret, :redirect_url
    attr_accessor :sub_domain

    # Setup a new oAuth connection requires you to set some default:
    # === Params
    # opts<Hash{String=>String}>:: options for your app
    # 
    # == Options(opts)
    # id<String>:: oAuth app id from SalesKing app registration
    # secret<String>:: oAuth app secret from SalesKing app registration
    # scope<String>:: permission your app requests
    # redirect_url<String>:: redirect url inside your app for auth dialog
    # sk_url<String>:: SalesKing base url, * is replaced with users subdomain, 
    #   no trailing slash, optional defaults to https://*.salesking.eu
    # sub_domain<String>:: optinal, will probably be set later after a users
    # provided his subdomain
    def initialize(opts)
      @id           = opts['id']
      @secret       = opts['secret']
      @scope        = opts['scope']
      @redirect_url = opts['redirect_url']
      @canvas_slug  = opts['canvas_slug']
      @sk_url       = opts['sk_url'] || "https://*.salesking.eu"
      @sub_domain   = opts['sub_domain']
    end

    # URL showing the auth dialog to the user
    #
    # === Returns
    # <String>:: URL with parameter
    def auth_dialog
      params = { :client_id   => @id,
                 :redirect_uri=> @redirect_url,
                 :scope       => @scope }
      "#{sk_url}/oauth/authorize?#{to_url_params(params)}"
    end

    # The app's canvas url inside SalesKing
    # === Returns
    # <String>:: URL
    def sk_canvas_url
      "#{sk_url}/app/#{@canvas_slug}"
    end

    # URL to get the access_token, used in the second step after you have
    # requested the authorization and gotten a code
    # The token url is located at /oauth/token 
    # === Parameter
    # code<String>:: code received after auth
    # === Returns
    # <String>:: Url with parameter
    def token_url(code)
      params = { :client_id     => @id,
                 :client_secret => @secret,
                 :redirect_uri  => @redirect_url,
                 :code          => code }
      "#{sk_url}/oauth/token?#{to_url_params(params)}"
    end

    # Makes a GET request to the access_token endpoint in SK and receives the
    # access token
    def get_token(code)
      c = Curl::Easy.perform( token_url( code ) )
      # grab token from response body, containing json string
      ActiveSupport::JSON.decode(c.body_str)
    end

    # The API url ist the salesking url of the current company + /api
    # === Returns
    # <String>:: base api url my-sub.salesking.eu/api
    def sk_api_url
      "#{sk_url}/api"
    end

    # Each company has it's own subdomain so the url must be dynamic.
    # This is achieved by replacing the * with the subdomain in the instance
    # === Returns
    # <String>:: url
    def sk_url
      @sk_url.gsub('*', sub_domain).gsub(/\/\z/, '' )
    end

    def to_url_params(params_hash)
      out = []
      params_hash.each { |k,v| out << "#{CGI::escape k.to_s}=#{CGI::escape v.to_s}" }
      out.join('&')
    end

  end
end