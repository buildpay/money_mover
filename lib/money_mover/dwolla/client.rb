module MoneyMover
  module Dwolla
    class Client
      delegate :api_url, :token_url, :auth_url, to: :@url_provider
      attr_reader :content_type

      def initialize(access_token = nil, url_provider = EnvironmentUrls.new, params = {})
        @url_provider = url_provider
        @content_type = params.fetch(:content_type, 'json')
        @connection = ApiConnection.new(access_token, url_provider, @content_type).connection
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
