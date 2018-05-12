module MoneyMover
  module Dwolla
    class WebhookSubscription < BaseModel
      attr_accessor :url, :secret
      validates_presence_of :url, :secret

      def to_params
        {
          url: url,
          secret: secret
        }
      end
    end
  end
end
