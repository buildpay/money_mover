module MoneyMover
  module Dwolla
    class RootAccount

      def initialize
        @account_info = ApplicationClient.new.get('/').body
        puts "#{@account_info}\n\n\n"
      end

      def account_resource_location
        @account_info.dig(:_links, :account, :href)
      end

      def account_resource_id
        account_resource_location.split('/').last rescue nil
      end

      def funding_sources
        @funding_sources ||= AccountFundingSourceResource.new.list({}, account_resource_id).embedded_items
        puts "#{@funding_sources}\n\n\n"
        @funding_sources
      end

      def bank_account_funding_source
        if funding_sources.empty?
          raise "funding sources are empty"
        end
        funding_sources.find{|source| source.name == 'Superhero Savings Bank' }
      end
    end
  end
end
