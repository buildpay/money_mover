require 'spec_helper'

describe MoneyMover::Dwolla::ReceiveOnlyCustomer do
  let(:firstName) { double 'firstname' }
  let(:lastName) { double 'lastname' }
  let(:email) { double 'email' }
  let(:businessName) { double 'businessName' }
  let(:ipAddress) { double 'ip address' }

  let(:attrs) do
    {
      firstName: firstName,
      lastName: lastName,
      email: email,
      businessName: businessName,
      ipAddress: ipAddress
    }
  end

  subject { described_class.new attrs }

  it { should validate_presence_of(:firstName) }
  it { should validate_presence_of(:lastName) }
  it { should validate_presence_of(:email) }

  describe '#to_params' do
    it 'returns expected values' do
      expect(subject.to_params).to eq({
        firstName: firstName,
        lastName: lastName,
        email: email,
        businessName: businessName,
        ipAddress: ipAddress,
        type: 'receive-only'
      })
    end

    context 'optional fields not set' do
      let(:businessName) { nil }
      let(:ipAddress) { nil }

      it 'returns expected values' do
        expect(subject.valid?).to eq(true)
        expect(subject.to_params).to eq({
          firstName: firstName,
          lastName: lastName,
          email: email,
          type: 'receive-only'
        })
      end
    end
  end
end
