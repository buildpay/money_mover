module MoneyMover
  module Dwolla
    class Passport < BaseModel
      attr_accessor :number, :country

      validates_presence_of :number, :country

      def to_params
        {
          number: number,
          country: country
        }
      end
    end
  end
end
