module MoneyMover
  module Dwolla
    class AccountFundingSourceResource < BaseResource
      list_filters :removed
      endpoint_path "/accounts/:account_id/funding-sources", action: [:list]
      endpoint_path "/funding-sources", action: [:create]
    end
  end
end
