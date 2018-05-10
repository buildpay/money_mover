module MoneyMover
  module Dwolla
    class UnverifiedCustomer < BaseModel
      attr_accessor :firstName,
        :lastName,
        :email,
        :type,
        :businessName,
        :ipAddress,
        :status,
        :created

      validates_presence_of :firstName, :lastName, :email

      def initialize(attributes={})
        super(attributes.merge(type: 'unverified'))
      end

      def to_params
        attrs = {
          firstName: firstName,
          lastName: lastName,
          email: email,
          type: type
        }
        attrs[:businessName] = businessName if businessName.present?
        attrs[:ipAddress] = ipAddress if ipAddress.present?
        attrs
      end
    end
  end
end
