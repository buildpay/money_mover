module MoneyMover
  module Dwolla
    class ApiConnection
      attr_reader :connection

      def initialize(access_token, url_provider)
        @connection ||= Faraday.new(url: url_provider.api_url) do |faraday|
          faraday.authorization :Bearer, access_token if access_token
          faraday.headers[:accept] = "application/vnd.dwolla.v1.hal+json"
          faraday.request :multipart
          faraday.request :url_encoded
          faraday.request :json
          faraday.response :json, content_type: /\bjson$/
          faraday.response :url_enconded, content_type: /\burl_encoded$/
          faraday.adapter Faraday.default_adapter
        end
      end
    end
  end
end
