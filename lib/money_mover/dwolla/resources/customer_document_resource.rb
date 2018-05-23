module MoneyMover
  module Dwolla
    class CustomerDocumentResource < BaseResource
      endpoint_path '/customers/:customer_id/documents', action: [:list, :create]
      endpoint_path '/documents/:id', action: [:find]
    end
  end
end
