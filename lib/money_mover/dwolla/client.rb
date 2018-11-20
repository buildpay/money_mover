module MoneyMover
  module Dwolla
    class Client
      delegate :api_url, :token_url, :auth_url, to: :@url_provider

      def initialize(access_token = nil, url_provider = EnvironmentUrls.new, content_type: 'json')
        @url_provider = url_provider
        puts "Content type is #{content_type}"
        @connection = ApiConnection.new(access_token, url_provider, content_type).connection
      end

      def post(url, params)
        ApiServerResponse.new @connection.post(url, params)
      end

      def get(url, params = nil)
        ApiServerResponse.new @connection.get(url, params)
      end

      def delete(url, params = nil)
        ApiServerResponse.new @connection.delete(url, params)
      end
    end
  end
end
