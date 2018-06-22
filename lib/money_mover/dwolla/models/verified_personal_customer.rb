module MoneyMover
  module Dwolla
    class VerifiedPersonalCustomer < BaseModel
      attr_accessor :firstName,
        :lastName,
        :email,
        :address1,
        :address2,
        :city,
        :state,
        :postalCode,
        :dateOfBirth,
        :ssn,
        :phone,
        :ipAddress,
        :status,
        :created
      attr_reader :type

      validates_presence_of :firstName,
        :lastName,
        :email,
        :address1,
        :city,
        :state,
        :postalCode,
        :dateOfBirth,
        :ssn

      def initialize(attributes={})
        @type = 'personal'
        super
      end

      def to_params
        {
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address1: address1,
          address2: address2,
          city: city,
          state: state,
          postalCode: postalCode,
          dateOfBirth: dateOfBirth,
          ssn: ssn,
          ipAddress: ipAddress,
          type: type
        }.compact
      end
    end
  end
end
