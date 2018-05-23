require 'spec_helper'

describe MoneyMover::Dwolla::Transfer do
  let(:funding_source_token) { 'funding_source_token' }
  let(:destination_source_token) { 'destination_source_token' }
  let(:amount) { '12.45' }
  let(:metadata) { { ach_tranfer_id: 123 } }

  let(:api_url) { 'https:://api/url' }
  let(:environment_urls) { double 'environment urls', api_url: api_url}
  before do
    allow(MoneyMover::Dwolla::EnvironmentUrls).to receive(:new) { environment_urls }
  end

  let(:transfer_success?) { true }

  let(:attrs) {{
    sender_funding_source_token: funding_source_token,
    destination_funding_source_token: destination_source_token,
    transfer_amount: amount,
    metadata: metadata
  }}

  subject { described_class.new(attrs) }

  it { should validate_presence_of(:sender_funding_source_token) }
  it { should validate_presence_of(:destination_funding_source_token) }
  it { should validate_presence_of(:transfer_amount) }

  describe '#to_params' do

    it 'returns expected value' do
      expect(subject.to_params).to eq({
        _links: {
          destination: {
            href: "#{api_url}/funding-sources/#{destination_source_token}"
          },
          source: {
            href: "#{api_url}/funding-sources/#{funding_source_token}"
          }
        },
        amount: {
          value: amount.to_s,
          currency: "USD"
        },
        metadata: metadata
      })
    end
  end
end
