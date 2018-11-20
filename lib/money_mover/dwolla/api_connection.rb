module MoneyMover
  module Dwolla
    class ApiConnection
      attr_reader :connection

      def initialize(access_token, url_provider, content_type)
        if content_type == 'json'
          @connection ||= Faraday.new(url: url_provider.api_url) do |faraday|
            faraday.authorization :Bearer, access_token if access_token
            faraday.headers[:accept] = "application/vnd.dwolla.v1.hal+json"
            faraday.request :multipart
            faraday.request :json
            faraday.response :json, content_type: /\bjson$/
            faraday.adapter Faraday.default_adapter
            puts "Sends out Json request"
          end
        elsif content_type == 'url_encoded'
          @connection ||= Faraday.new(url: url_provider.api_url) do |faraday|
            faraday.authorization :Bearer, access_token if access_token
            faraday.headers[:accept] = "application/json"
            faraday.headers[:content_type] = "application/x-www-form-urlencoded"
            faraday.response :json, content_type: /\bjson$/
            faraday.adapter Faraday.default_adapter
            puts "Sends out encoded url request"
          end
        else
          raise "Request header should have a content type of json or encoded url"
        end
      end
    end
  end
end
