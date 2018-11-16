module MoneyMover
  module Dwolla
    class ApiConnection
      attr_reader :connection

      def initialize(access_token, url_provider)
        @connection ||= Faraday.new(url: url_provider.api_url) do |faraday|
          faraday.authorization :Bearer, access_token if access_token
          faraday.headers[:accept] = "application/json"
          faraday.headers[:content_type] = "application/x-www-form-urlencoded"
          faraday.request :multipart
          faraday.response :json, content_type: /\bjson$/
          faraday.adapter Faraday.default_adapter
        end
      end
    end
  end
end
