module MoneyMover
  module Dwolla
    class CustomerResource < BaseResource
      list_filters :search, :status, :limit, :offset
      endpoint_path "/customers", action: [:list, :create]
      endpoint_path "/customers/:id", action: [:update, :destroy, :find]
    end
  end
end
