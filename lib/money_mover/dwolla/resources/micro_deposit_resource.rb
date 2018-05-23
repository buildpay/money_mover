module MoneyMover
  module Dwolla
    class MicroDepositResource < BaseResource
    endpoint_path '/funding-sources/:funding_source_id/micro-deposits', action: [:update, :find]

      def initiate(funding_source_id)
        path = get_path(:update, [funding_source_id])

        errors.clear
        response = client.post path, {}
        unless response.success?
          add_errors_from response
        end

        errors.empty?
      end
    end
  end
end
