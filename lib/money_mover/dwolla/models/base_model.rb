module MoneyMover
  module Dwolla
    class BaseModel
      include ActiveModel::Validations
      include ActiveModel::AttributeAssignment

      attr_accessor :id

      def initialize(attributes = {})
        assign_attributes(attributes) if attributes
        super()
      end
    end
  end
end
