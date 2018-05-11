module MoneyMover
  module Dwolla
    class UnverifiedBusinessCustomer < UnverifiedCustomer
      validates_presence_of :businessName
    end
  end
end
