module MoneyMover
  module Dwolla
    class CustomerBeneficialOwner < BaseModel
      attr_accessor :firstName, :lastName, :dateOfBirth, :ssn
      attr_reader :passport, :address

      validates_presence_of :firstName, :lastName, :dateOfBirth, :address
      validate :validate_associated_address, if: -> { address.present? }
      validate :validate_ssn_or_passport

      def passport=(attrs={})
        @passport = Passport.new(attrs)
      end

      def address=(attrs={})
        @address = ExtendedAddress.new(attrs)
      end

      def to_params
        attrs = {
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth
        }
        attrs[:address] = address.to_params if address
        attrs[:ssn] = ssn if ssn
        attrs[:passport] = passport.to_params if passport
        attrs
      end

      private

      def validate_associated_address
        unless address.valid?
          address.errors.full_messages.each do |message|
            errors.add :address, message
          end
        end
      end

      def validate_ssn_or_passport
        unless ssn.present? || (passport.present? && passport.valid?)
          errors.add :base, "SSN or Passport information must be provided"
        end
      end
    end
  end
end
