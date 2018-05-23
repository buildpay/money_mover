module MoneyMover
  module Dwolla
    class CustomerBeneficialOwnerResource < BaseResource
      endpoint_path "/customers/:customer_id/beneficial-owners", action: [:list, :create]
      endpoint_path "/beneficial-owners/:id", action: [:update, :destroy, :find]

      def certify_beneficial_ownership(id)
        path = "/customers/#{id}/beneficial-ownership"

        errors.clear
        response = client.post path, { status: 'certified' }
        unless response.success?
          add_errors_from response
        end

        errors.empty?
      end
    end
  end
end
