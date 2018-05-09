module MoneyMover
  module Dwolla
    class CustomerBeneficialOwnerResource < BaseResource
      endpoint_path "/customers/:customer_id/beneficial-owners", action: [:list, :create]
      #endpoint_path "beneficial-owners/:id"
    end
  end
end
