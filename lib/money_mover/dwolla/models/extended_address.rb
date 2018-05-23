module MoneyMover
  module Dwolla
    class ExtendedAddress < BaseModel
      attr_accessor :address1,
        :address2,
        :address3,
        :city,
        :stateProvinceRegion,
        :postalCode,
        :country

      validates_presence_of :address1,
        :city,
        :stateProvinceRegion,
        :postalCode,
        :country

      def to_params
        {
          address1: address1,
          address2: address2,
          address3: address3,
          city: city,
          stateProvinceRegion: stateProvinceRegion,
          postalCode: postalCode,
          country: country
        }
      end
    end
  end
end
