module MoneyMover
  module Dwolla
    class CustomerBeneficialOwner < BaseModel
      attr_accessor :firstName,
        :lastName,
        :ssn,
        :dateOfBirth,
        :address1,
        :address2,
        :address3,
        :city,
        :state,
        :postalCode,
        :passportNumber,
        :passportCountry

      validates_presence_of :firstName,
        :lastName,
        :dateOfBirth,
        :address1,
        :city,
        :state,
        :postalCode

      validate :official_identifier_valid


      def to_params
        attrs = {
          firstName: firstName,
          lastName: lastName,
          ssn: ssn,
          dateOfBirth: dateOfBirth,
          address: address_params,
          passport: passport_params
        }.compact
      end

      def address_params
        attrs = {
          address1: address1,
          address2: address2,
          address3: address3,
          city: city,
          state: state,
          postalCode: postalCode,
          country: country
        }
      end

      def passport_params
        {
          number: passportNumber,
          country: passportCountry
        }
      end

      def validate_identifier_valid
        unless ssn.present? ||
            (passportNumber.present? && passportCountry.present?)
          errors.add :base, "Controller SSN or Passport information must be provided"
        end
      end
    end
  end
end
