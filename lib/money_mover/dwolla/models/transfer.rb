module MoneyMover
  module Dwolla
    class Transfer < BaseModel
      attr_accessor :sender_funding_source_token, :destination_funding_source_token, :transfer_amount, :metadata

      validates_presence_of :sender_funding_source_token, :destination_funding_source_token, :transfer_amount

      def to_params
        {
          _links: {
            destination: {
              href: "#{api_url}/funding-sources/#{@destination_funding_source_token}"
            },
            source: {
              href: "#{api_url}/funding-sources/#{@sender_funding_source_token}"
            }
          },
          amount: {
            value: @transfer_amount.to_s,
            currency: "USD"
          },
          metadata: @metadata
        }
      end

      private

      # TODO petition Dwolla not require full urls as part of our parameter values!
      def api_url
        @api_url ||= EnvironmentUrls.new.api_url
      end
    end
  end
end
