module MoneyMover
  module Dwolla
    class ReceiveOnlyBusinessCustomer < ReceiveOnlyCustomer
      validates_presence_of :businessName
    end
  end
end
