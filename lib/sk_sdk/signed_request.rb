require 'base64'
require "active_support/json"
require 'openssl'
module SK::SDK
  # Decode and validate signed requests which Salesking sends to canvas pages
  # and PubSub subscribers
  class SignedRequest

    attr_reader :signed_request, :app_secret, :data, :payload, :sign

    def initialize(signed_request, app_secret)
      @signed_request = signed_request
      @app_secret = app_secret
      decode_payload
    end

    # Populate @data and @sign(ature) by splitting and decoding the incoming
    # signed_request
    def decode_payload
      @sign, @payload = @signed_request.split('.')
      @data = ActiveSupport::JSON.decode base64_url_decode(@payload)
    end

    # Decode a base64URL encoded string: replace - with + and _ with /
    # Also add padding so ruby's Base64 can decode it
    # === returns
    # <String>:: the plain string decoded
    def base64_url_decode(str)
      encoded_str = str.tr('-_', '+/')
      encoded_str += '=' while !(encoded_str.size % 4).zero?
      Base64.decode64(encoded_str)
    end

    # A request is valid if the new hmac created from the incoming string matches
    # the new one, created with the apps secret
    def valid?
      return false if @data['algorithm'].to_s.upcase != 'HMAC-SHA256'
      @sign == OpenSSL::HMAC.hexdigest('sha256', @app_secret, @payload)
    end

    def encode(str)
      # base65 url encode the json, remove trailing-padding =
      enc_str = [str].pack('m').tr('+/','-_').gsub("\n",'').gsub(/=+$/, '' )
      # create hmac signature
      hmac_sig = OpenSSL::HMAC.hexdigest('sha256',@app_secret, enc_str)
      # glue together and return
      [hmac_sig, enc_str].join('.')
    end
  end
end