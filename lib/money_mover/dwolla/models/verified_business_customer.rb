module MoneyMover
  module Dwolla
    class VerifiedBusinessCustomer < Customer
      CONTROLER_EXEMPT_BUSINESS_TYPES = ['soleproprietorship']

      validates_presence_of :firstName,
        :lastName,
        :email,
        :address1,
        :city,
        :state,
        :postalCode,
        :dateOfBirth,
        :ssn,
        :phone,
        :businessClassification,
        :businessType,
        :businessName,
        :ein

      validates_presence_of :controllerFirstName,
        :controllerLastName,
        :controllerTitle,
        :controllerDateOfBirth,
        :controllerAddress1,
        :controllerCity,
        :controllerState,
        :controllerPostalCode,
        :controllerCountry, if: :controller_required?
      validate :controller_identifier_valid, if: :controller_required?

      #validates_inclusion_of :businessType, in: COMPANY_TYPES

      private

      def create_params
        create_attrs = {
          firstName: firstName,
          lastName: lastName,
          email: email,
          address1: address1,
          address2: address2,
          city: city,
          state: state,
          postalCode: postalCode,
          dateOfBirth: dateOfBirth,
          ssn: ssn,
          phone: phone,
          businessClassification: businessClassification,
          businessType: businessType,
          businessName: businessName,
          ein: ein,
          doingBusinessAs: doingBusinessAs,
          website: website_with_protocol,
          ipAddress: ipAddress,
          type: 'business',
          controller: controller_params
        }

        # hack to fix bug on dwolla's side with funding sources being removed if no dba is sent
        create_attrs[:doingBusinessAs] = businessName unless doingBusinessAs.present?

        create_attrs.reject{|_key, val| !val.present? }
      end

      def controller_required?
        businessType.present? && !CONTROLER_EXEMPT_BUSINESS_TYPES.include?(businessType.downcase)
      end

      def controller_params
        if controller_required?
          {
            firstName: controllerFirstName,
            lastName: controllerLastName,
            title: controllerTitle,
            dateOfBirth: controllerDateOfBirth,
            ssn: controllerSsn,
            passport: controller_passport_params,
            address: controller_address_params
          }.reject{|_key, val| !val.present? }
        end
      end

      def controller_address_params
        {
          address1: controllerAddress1,
          address2: controllerAddress2,
          address3: controllerAddress3,
          city: controllerCity,
          state: controllerState,
          postalCode: controllerPostalCode,
          country: controllerCountry
        }.reject{|_key, val| !val.present? }
      end

      def controller_passport_params
        {
          number: controllerPassportNumber,
          country: controllerPassportCountry
        }.reject{|_key, val| !val.present? }
      end

      def controller_identifier_valid
        unless controllerSsn.present? ||
            (controllerPassportNumber.present? && controllerPassportCountry.present?)
          errors.add :base, "Controller SSN or Passport information must be provided"
        end
      end
    end
  end
end
