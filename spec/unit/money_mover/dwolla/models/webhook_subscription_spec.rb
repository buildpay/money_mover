require 'spec_helper'

describe MoneyMover::Dwolla::WebhookSubscription do
  let(:url) { double 'url' }
  let(:secret) { double 'secret' }

  subject { described_class.new(url: url, secret: secret) }

  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:secret) }

  describe '#to_params' do
    it 'should return expected values' do
      expect(subject.to_params).to eq({
        url: url,
        secret: secret
      })
    end
  end
end
