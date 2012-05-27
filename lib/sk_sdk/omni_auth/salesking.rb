require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Salesking < OAuth2
      # SalesKing requires a subdomain up front
      # It needs to be provided in a form and retrieved from the request
      # The one on init is not used as it is grabbed from the session later
      #
      # @param [Rack Application] app  rack middleware application
      # @param [String] client_id the application id as registered on SalesKing
      # @param [String] client_secret the application secret as registered on SalesKing
      # @param [String] sk_url
      # @param [String] scope space separated extended permissions such as
      #   `api/invoices` or `api/clients:read,delete api/orders`
      def initialize(app, client_id, client_secret, sk_url, scope)
        @base_url = sk_url
        @scope = scope
        client_options = {:access_token_path => '/oauth/token'}
        super(app, :salesking, client_id, client_secret, client_options)
      end

      # inject salesking url and scope into OmniAuth
      def request_phase
        options[:scope] = @scope
        set_sk_url
        super
      end

      # Monkey-patching to inject subdomain again into OmniAuth
      def callback_phase
        set_sk_url
        super
      end

      # @return [Hash] user currently logged in
      def user_data
        @data ||= begin
          ret = MultiJson.decode(@access_token.get('api/users/current'))
          ret['user']
        end
      end

      def user_info
        {
          'email' => (user_data["email"] if user_data["email"]),
          'first_name' => user_data["first_name"],
          'last_name' => user_data["last_name"],
          'name' => "#{user_data['first_name']} #{user_data['last_name']}"
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
#          'uid' => "#{user_data['current_company']['company']['id']}.#{user_data['id']}",
          'uid' => user_data['id'],
          'user_info' => user_info,
          'credentials' => {
            'expires_in' => @access_token.expires_in
          },
          'extra' => {'user_hash' => user_data}
        })
      end

      # Each company has it's own subdomain so the url must be dynamic.
      # This is achieved by replacing the * with the subdomain from the session
      # @return [String] url with subdomain of sk user
      def set_sk_url
        client_options[:site] = @base_url.gsub('*', session[:subdomain]).gsub(/\/\z/, '' )
      end
    end
  end
end