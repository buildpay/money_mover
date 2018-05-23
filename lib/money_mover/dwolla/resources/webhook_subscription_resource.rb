module MoneyMover
  module Dwolla
    class WebhookSubscriptionResource < BaseResource
      endpoint_path '/webhook-subscriptions', action: [:list, :create]
      endpoint_path '/webhook-subscriptions/:id', action: [:find, :update, :destroy]
    end
  end
end
