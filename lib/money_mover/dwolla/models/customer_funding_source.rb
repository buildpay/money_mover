module MoneyMover
  module Dwolla
    class CustomerFundingSource < BaseModel
      attr_accessor :name, :bankAccountType, :routingNumber, :accountNumber

      validates_presence_of :name, :bankAccountType, :routingNumber, :accountNumber
      validates_inclusion_of :bankAccountType, :in => %w( checking savings )

      def to_params
        {
          name: name,
          bankAccountType: bankAccountType,
          routingNumber: routingNumber,
          accountNumber: accountNumber
        }
      end
    end
  end
end
