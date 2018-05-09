module MoneyMover
  module Dwolla
    class CustomerBeneficialOwner < ApiResource
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

      def initialize(customer_id, attrs={})
        @customer_id = customer_id
        super attrs
      end

      def self.find(id)
        client = ApplicationClient.new

        response = client.get fetch_endpoint(id)

        if response.success?
          new response.body
        else
          raise 'Customer Beneficial Owner Not Found'
          #puts "error: #{response.body}"
        end
      end

      private

      def fetch_endpoint(id)
        "/beneficial-owners/#{id}"
      end

      def create_endpoint
        "/customers/#{@customer_id}/beneficial-owners"
      end

      def create_params
        create_attrs = {
          firstName: firstName,
          lastName: lastName,
          ssn: ssn,
          dateOfBirth: dateOfBirth,
          address: address_params,
          passport: passport_params
        }.reject{|_key, val| !val.present? }
      end

      def address_params
        {
          address1: address1,
          address2: address2,
          address3: address3,
          city: city,
          state: state,
          postalCode: postalCode,
          country: country
        }.reject{|_key, val| !val.present? }
      end

      def passport_params
        {
          number: passportNumber,
          country: passportCountry
        }.reject{|_key, val| !val.present? }
      end

      def official_identifier_valid
        unless ssn.present? ||
            (passportNumber.present? && passportCountry.present?)
          errors.add :base, "Controller SSN or Passport information must be provided"
        end
      end
    end
  end
end
