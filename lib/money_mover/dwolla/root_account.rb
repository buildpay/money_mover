module MoneyMover
  module Dwolla
    class RootAccount

      def initialize
        @account_info = ApplicationClient.new.get('/').body
        puts "#{@account_info}"
      end

      def account_resource_location
        @account_info.dig(:_links, :account, :href)
      end

      def account_resource_id
        account_resource_location.split('/').last rescue nil
      end

      def funding_sources
        @funding_sources ||= AccountFundingSourceResource.new.list({}, account_resource_id).embedded_items
        puts "#{@funding_sources}"
      end

      def bank_account_funding_source
        funding_sources.find{|source| source.type == 'bank' }
      end
    end
  end
end
