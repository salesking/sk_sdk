require 'cgi'
require 'sk_sdk'

module SK::SDK
  # Authenticate your SalesKing App using oAuth2. This class provides helpers
  # to create the token & dialog url and build the params to get an access token.
  # ==Example
  # Using httparty gem:
  #
  #    require 'sk_sdk/oauth'
  #    require 'httparty'
  #
  #    auth = SK::SDK::Oauth.new(sk_app_settings)
  #    resp = HTTParty.post(token_url,
  #                          body: auth.token_params(code),
  #                          basic_auth: auth.basic_params )
  # Of course you can use curb or any other http lib. Just make sure to read
  # their docs about POST params, HTTP BASIC Auth and https handling
  class Oauth

    attr_reader :id, :secret, :redirect_url
    attr_accessor :sub_domain

    # Setup a new oAuth connection requires you to set some default:
    #
    # @param[Hash{String=>String}] opts containing id, secrete, scope, url of
    #   your app
    # @option [String] id oAuth app id from SalesKing app registration
    # @option [String] secret oAuth app secret from SalesKing app registration
    # @option [String|Array[String]] permission scopes for your app requests
    # @option [String] redirect_url inside your app for auth dialog
    # @option [String] sk_url SalesKing base url, * is replaced with users subdomain,
    #   no trailing slash, optional defaults to https://*.salesking.eu
    # @option [String] sub_domain optional, will probably be set later after a users
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

    # @return [String] URL with parameter to show the auth dialog to the user
    def auth_dialog
      scope_string = Array === @scope ? @scope.join(' ') : @scope
      params = { :client_id   => @id,
                 :redirect_uri=> @redirect_url,
                 :scope       => scope_string }
      "#{sk_url}/oauth/authorize?#{to_url_params(params)}"
    end

    # @return [String] app's canvas url inside SalesKing
    def sk_canvas_url
      "#{sk_url}/app/#{@canvas_slug}"
    end

    # URL to get the access_token, used in the second step after you have
    # requested the authorization and gotten a code
    # The token url is located at /oauth/token
    def token_url
      "#{sk_url}/oauth/token"
    end

    # Params used in the POST request to /token e.g see httparty example on top.
    # Using the client_secret in the params is DEPRECATED. Instead use HTTP Basic
    # Auth header with client_id:client_secret like provided by #basic_params
    # @returns[Hash] params used to get the real access-token
    # @param [String] code to exchange for the access token
    def token_params(code)
      { client_id: @id,
        grant_type: 'authorization_code',
        redirect_uri: CGI::escape(@redirect_url),
        code: code }
    end

    # HTTP BASIC Auth Params used in the POST request to /token e.g with httparty
    def basic_params
      { username: @id, password: @secret }
    end

    # @return [String] base api url my-sub.salesking.eu/api
    def sk_api_url
      "#{sk_url}/api"
    end

    # Each company has it's own subdomain so the url must be dynamic.
    # This is achieved by replacing the * with the subdomain in the instance if
    # a sub_domain was given. Else the SalesKing domain MUST include the subdomain
    # @return [String] url
    def sk_url
      return @sk_url unless sub_domain
      @sk_url.gsub('*', sub_domain).gsub(/\/\z/, '' )
    end

    def to_url_params(params_hash)
      params_hash.map { |k,v| "#{CGI::escape k.to_s}=#{CGI::escape v.to_s}" }.join('&')
    end

  end
end
