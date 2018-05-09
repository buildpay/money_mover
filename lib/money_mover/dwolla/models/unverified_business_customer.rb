module MoneyMover
  module Dwolla
    class UnverifiedBusinessCustomer < BaseModel
      attr_accessor :firstName,
        :lastName,
        :email,
        :ipAddress,
        :type,
        :created,
        :address1,
        :address2,
        :city,
        :state,
        :postalCode,
        :dateOfBirth,
        :ssn,
        :phone,
        :businessClassification,
        :businessType,
        :businessName,
        :ein,
        :doingBusinessAs,
        :website,
        :ipAddress

      validates_presence_of :firstName, :lastName, :email, :businessName

      def initialize(attributes = {})
        super(attributes.merge(type: 'business'))
      end

      # TODO KLC get rid of invalid attributes!

      def to_params
        attrs = {
          firstName: firstName,
          lastName: lastName,
          email: email,
          businessName: businessName,
          doingBusinessAs: doingBusinessAs, # not required
          ipAddress: ipAddress,
          type: type,
          #address1: address1,
          #address2: address2,
          #city: city,
          #state: state,
          #postalCode: postalCode,
          #dateOfBirth: dateOfBirth,
          #ssn: ssn,
          #phone: phone,
          #businessClassification: businessClassification,
          #businessType: businessType,
          #businessName: businessName,
          #ein: ein,
          #doingBusinessAs: doingBusinessAs,
          #website: website_with_protocol,
        }

        # hack to fix bug on dwolla's side with funding sources being removed if no dba is sent
        attrs[:doingBusinessAs] = businessName unless doingBusinessAs.present?
        attrs[:type] = 'unverified'

        attrs.compact
      end
    end
  end
end
