module MoneyMover
  module Dwolla
    class ApiConnection
      attr_reader :connection

      def initialize(access_token, url_provider)
        @connection ||= Faraday.new(url: url_provider.api_url) do |faraday|
          faraday.authorization :Bearer, access_token if access_token
          faraday.headers[:accept] = "application/vnd.dwolla.v1.hal+json"
          faraday.headers[:content_type] = "application/x-www-form-urlencoded"
          faraday.response :json, content_type: "application/json"
          faraday.adapter Faraday.default_adapter
        end

        puts "\n\n\n\n"
        puts "#{@connection.to_json}"
        puts "\n\n\n\n"

        @connection
      end
    end
  end
end
