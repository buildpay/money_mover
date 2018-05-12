require 'money_mover/dwolla/config'
require 'money_mover/dwolla/api_connection'
require 'money_mover/dwolla/api_server_response'
require 'money_mover/dwolla/resources/base_resource'

# token stuff
require 'money_mover/dwolla/client'
require 'money_mover/dwolla/token'
require 'money_mover/dwolla/application_client'
require 'money_mover/dwolla/application_token'
require 'money_mover/dwolla/root_account' # helper to get dwolla api account info (whitelabel account token and funding-sources)

require 'money_mover/dwolla/environment_urls'
require 'money_mover/dwolla/error_handler'

require 'money_mover/dwolla/models/api_resource'

# models
require 'money_mover/dwolla/models/base_model'
require 'money_mover/dwolla/models/extended_address'
require 'money_mover/dwolla/models/passport'
require 'money_mover/dwolla/models/document'
require 'money_mover/dwolla/models/customer_funding_source'
require 'money_mover/dwolla/models/micro_deposit_verification'
require 'money_mover/dwolla/models/transfer'
# customer models
require 'money_mover/dwolla/models/customer'
require 'money_mover/dwolla/models/receive_only_customer'
require 'money_mover/dwolla/models/receive_only_business_customer'
require 'money_mover/dwolla/models/unverified_customer'
require 'money_mover/dwolla/models/unverified_business_customer'
require 'money_mover/dwolla/models/customer_beneficial_owner'
require 'money_mover/dwolla/models/verified_business_customer'
require 'money_mover/dwolla/models/webhook_subscription'

# model specific api resources
require 'money_mover/dwolla/resources/account_funding_source_resource'
require 'money_mover/dwolla/resources/customer_resource'
require 'money_mover/dwolla/resources/customer_funding_source_resource'
require 'money_mover/dwolla/resources/micro_deposit_resource'
require 'money_mover/dwolla/resources/customer_beneficial_owner_resource'
require 'money_mover/dwolla/resources/customer_transfer_resource'
require 'money_mover/dwolla/resources/customer_document_resource'
require 'money_mover/dwolla/resources/webhook_subscription_resource'

# other stuff
require 'money_mover/dwolla/request_signature_validator'

module MoneyMover
  module Dwolla
    @config_provider = nil

    class << self
      attr_accessor :config_provider
    end
  end
end
