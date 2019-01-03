module MoneyMover
  module Dwolla
    class EnvironmentUrls
      ENVIRONMENTS = {
        :production => {
          :auth_url  => "http://localhost:55034/oauth/v2/authenticate",
          :token_url => "http://localhost:55034/oauth/v2/token",
          :api_url   => "http://localhost:55034"
        },
        :sandbox => {
          :auth_url  => "http://localhost:55034/oauth/v2/authenticate",
          :token_url => "http://localhost:55034/oauth/v2/token",
          :api_url   => "http://localhost:55034"
        }
      }

      def initialize(ach_config = Config.new)
        @ach_config = ach_config
        @environment = @ach_config.environment.to_sym
      end

      def api_url
        ENVIRONMENTS[@environment][:api_url]
      end

      def token_url
        ENVIRONMENTS[@environment][:token_url]
      end

      def auth_url
        ENVIRONMENTS[@environment][:auth_url]
      end
    end
  end
end
