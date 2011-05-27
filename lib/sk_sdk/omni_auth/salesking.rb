require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Salesking < OAuth2
      # SalesKing requires a subdomain up front
      # It needs to be provided in a form and retrieved from the request
      # The one on init is not used as it is grabbed from the session later
      # === Params
      # app<Rack Application]>:: app standard middleware application parameter
      # client_id<String>:: the application id as registered on SalesKing
      # client_secret<String>::  the application secret as registered on SalesKing
      # scope<String>:: space separated extended permissions such as `api/invoices` or `api/clients:read,delete`
      def initialize(app, client_id, client_secret, sk_url, scope)
        @base_url = sk_url
        @scope = scope
        super(app, :salesking, client_id, client_secret)
      end

      #inject salesking url and scope
      def request_phase
        options[:scope] = @scope
        set_sk_url
        super
      end

      #Monkey-patching to inject subdomain again
      def callback_phase
        set_sk_url
        super
      end

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
      # === Returns
      # <String>:: url
      def set_sk_url
        client_options[:site] = @base_url.gsub('*', session[:subdomain]).gsub(/\/\z/, '' )
      end
    end
  end
end