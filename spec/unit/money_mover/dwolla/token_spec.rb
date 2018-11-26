require 'spec_helper'

describe MoneyMover::Dwolla::ApplicationToken do
  let(:ach_config) { double 'ach config', api_key: ach_config_api_key, api_secret_key: ach_config_api_secret_key, environment: ach_config_environment, account_token_provider: account_token_provider }
  let(:ach_config_api_key) { double 'ach config api key' }
  let(:ach_config_api_secret_key) { double 'ach config api secret' }
  let(:ach_config_environment) { double 'ach config environment' }
  let(:account_token_provider) { double 'account token provider', access_token: account_access_token }
  let(:account_access_token) { double 'account access token' }

  let(:attrs) {{}}

  subject { described_class.new attrs, ach_config }

  describe '#access_token' do
    it 'returns account token from account token provider' do
      expect(subject.access_token).to eq(account_access_token)
    end
  end
end

# INTEGRATION TEST
describe MoneyMover::Dwolla::ApplicationToken do
  let(:refresh_token_request_params) { dwolla_helper.request_token_request_body }

  let(:account_id) { "7da912eb-5976-4e5c-b5ab-a5df35ac661b" }
  let(:access_token) { "oNGSeXqucdVxTLAwSRNc1WjG5BTHWNS5z7hccJGUTGvCXusmbC" }

  let(:refresh_token_success_response) {{
    "_links": {
      "account": {
        "href":"https://api-uat.dwolla.com/accounts/#{account_id}"
      }
    },
    "access_token": access_token,
    "expires_in":3600,
    "refresh_expires_in":5184000,
    "token_type":"bearer",
    "scope":"accountinfofull|contacts|transactions|balance|send|request|funding|manageaccount|scheduled|email|managecustomers",
    "account_id": account_id
  }}

  describe '#request_new_token!' do
    let(:subject) { double 'subject', request_new_token!: request_new_token!}
    let(:request_new_token!) { new_token }

    let(:content_type) { 'url_encoded' }
    let(:url_provider) { double 'url provider'}

    let(:client) { double 'client', post: server_response }
    let(:api_connection) { double 'api connection', connection: faraday_connection }
    let(:faraday_connection) { double 'faraday connection', post: server_request.response }
    let(:server_request) { double 'server request', response: server_response }

    let(:server_response) { refresh_token_success_response }
    let(:server_response_body) { server_response.to_json }
    let(:server_response_parsed) { JSON.parse(server_response_body) }

    let(:new_token) { double 'new token', account_id: new_token_account_id, expires_in: new_token_expires_in, access_token: new_token_access_token}
    let(:new_token_account_id) { server_response_parsed["account_id"] }
    let(:new_token_expires_in) { server_response_parsed["expires_in"] }
    let(:new_token_access_token) { server_response_parsed["access_token"] }

    before do
      allow(MoneyMover::Dwolla::Client).to receive(:new).with(content_type: content_type) { client }
      allow(MoneyMover::Dwolla::EnvironmentUrls).to receive(:new) { url_provider }
      allow(MoneyMover::Dwolla::ApiConnection).to receive(:new).with(nil, url_provider, content_type) { api_connection }
      allow(MoneyMover::Dwolla::ApiServerResponse).to receive(:new).with(server_request) { server_response }
      allow(MoneyMover::Dwolla::Token).to receive(:new).with(server_response_body) { new_token }
    end

    context 'success' do
      it 'updates token' do
        new_token = subject.request_new_token!

        expect(new_token.account_id).to eq(account_id)
        expect(new_token.expires_in).to eq(3600)
        expect(new_token.access_token).to eq(access_token)
      end
    end
  end
end
