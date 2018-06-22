module MoneyMover
  module Dwolla
    class AccountFundingSourceResource < BaseResource
      list_filters :removed
      endpoint_path "/accounts/:account_id/funding-sources", action: [:list]
      endpoint_path "/funding-sources", action: [:create]

      def soft_delete(id)
        path = "/funding-sources/#{id}"

        errors.clear
        response = client.post path, { removed: true }

        unless response.success?
          add_errors_from response
        end

        errors.empty?
      end
    end
  end
end
