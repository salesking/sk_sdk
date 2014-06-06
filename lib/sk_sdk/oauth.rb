require 'cgi'
require 'httpi'
require 'sk_sdk'

module SK::SDK
  # Authenticate your SalesKing App using oAuth2. This class provides helpers
  # to create the token & dialog url and to get an access token
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
    #
    # @param [String] code received after auth
    # @return [String] Url with parameter
    def token_url(code)
      params = { :client_id     => @id,
                 :client_secret => @secret,
                 :redirect_uri  => @redirect_url,
                 :code          => code }
      "#{sk_url}/oauth/token?#{to_url_params(params)}"
    end

    # Makes a GET request to the access_token endpoint in SK and receives the
    # access token
    # @param [String] code request token
    # @return [Hash{String=>String}] access token
    def get_token(code)
      r = HTTPI::Request.new( token_url( code ) )
      if sk_url[/dev\.salesking.eu/] # as long as we are using a self signed cert
        r.auth.ssl.verify_mode = :none
      end
      r = HTTPI.get r
      # grab token from response body
      ActiveSupport::JSON.decode(r.body)
    end

    # @return [String] base api url my-sub.salesking.eu/api
    def sk_api_url
      "#{sk_url}/api"
    end

    # Each company has it's own subdomain so the url must be dynamic.
    # This is achieved by replacing the * with the subdomain in the instance
    #
    # @return [String] url
    def sk_url
      @sk_url.gsub('*', sub_domain).gsub(/\/\z/, '' )
    end

    def to_url_params(params_hash)
      params_hash.map { |k,v| "#{CGI::escape k.to_s}=#{CGI::escape v.to_s}" }.join('&')
    end

  end
end
