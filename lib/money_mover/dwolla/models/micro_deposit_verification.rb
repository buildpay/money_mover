module MoneyMover
  module Dwolla
    class MicroDepositVerification < BaseModel
      attr_accessor :amount1, :amount2

      validates_presence_of :amount1, :amount2
      validates_numericality_of :amount1, less_than_or_equal_to: 0.10, greater_than: 0
      validates_numericality_of :amount2, less_than_or_equal_to: 0.10, greater_than: 0

      def to_params
        {
          amount1: {
            value: amount1,
            currency: "USD"
          },
          amount2: {
            value: amount2,
            currency: "USD"
          }
        }
      end
    end
  end
end
