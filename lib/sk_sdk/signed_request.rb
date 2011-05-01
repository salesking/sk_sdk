require 'base64'
require "active_support/json"
require 'openssl'
require 'sk_sdk'

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

    # Base64 url encode a string and sign it using the given secret. The hmac
    # signature and the encoded string are joined by . and returned
    #
    # === Parameter
    # str<String>:: the string to encode
    # secret<String>:: the string used to create the signature
    # === Returns
    # <String>:: hmac-sign.encoded-string
    def self.signed_param(str, secret)
      # base65 url encode the json, remove trailing-padding =
      enc_str = base64_url_encode(str)
      # create hmac signature
      hmac_sig = OpenSSL::HMAC.hexdigest('sha256',secret, enc_str)
      # glue together and return
      [hmac_sig, enc_str].join('.')
    end

    # Base64 url encode a string:
    #  NO padding '=' is stripped
    # + is replaced by -
    # / is replaced by _
    #
    # === Parameter
    # str<String>:: the string to encode
    # === Returns
    # <String>:: base64url-encoded
    def self.base64_url_encode(str)
      [str].pack('m').tr('+/','-_').gsub("\n",'').gsub(/=+$/, '' )
    end

  end
end