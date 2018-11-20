module MoneyMover
  module Dwolla
    class ApplicationClient < Client
      def initialize
        super access_token = ApplicationToken.new.access_token
      end
    end
  end
end
