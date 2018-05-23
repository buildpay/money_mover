module MoneyMover
  module Dwolla
    class ReceiveOnlyCustomer < BaseModel
      attr_accessor :firstName, :lastName, :email, :businessName, :ipAddress
      attr_reader :type

      validates_presence_of :firstName, :lastName, :email

      def initialize(attributes={})
        @type = 'receive-only'
        super
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
