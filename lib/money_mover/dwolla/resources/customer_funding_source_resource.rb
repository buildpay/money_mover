module MoneyMover
  module Dwolla
    class CustomerFundingSourceResource < BaseResource
      list_filters :removed
      endpoint_path "/customers/:customer_id/funding-sources", action: [:list, :create]
      endpoint_path "/funding-sources/:id", action: [:update, :destroy, :find]
    end
  end
end
