module MoneyMover
  module Dwolla
    class ReceiveOnlyCustomer < BaseModel
      attr_accessor :firstName, :lastName, :email, :ipAddress, :type
      validates_presence_of :firstName, :lastName, :email

      def initialize(attributes={})
        super(attributes.merge(type: 'receive-only'))
      end

      def to_params
        attrs = {
          firstName: firstName,
          lastName: lastName,
          email: email,
          type: type,
        }
        attrs[:ipAddress] = ipAddress if ipAddress.present?
        attrs
      end
    end
  end
end
