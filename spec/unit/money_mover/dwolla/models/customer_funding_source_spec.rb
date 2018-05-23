require 'spec_helper'

describe MoneyMover::Dwolla::CustomerFundingSource do
  let(:name) { 'some name' }
  let(:bankAccountType) { 'checking' }
  let(:routingNumber) { 'routing number' }
  let(:accountNumber) { 'account number' }

  let(:attrs) {{
    name: name,
    bankAccountType: bankAccountType,
    routingNumber: routingNumber,
    accountNumber: accountNumber
  }}

  subject { described_class.new attrs }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:bankAccountType) }
  it { should validate_presence_of(:routingNumber) }
  it { should validate_presence_of(:accountNumber) }
  it { should validate_inclusion_of(:bankAccountType).in_array(['checking', 'savings'])}

  describe '#to_params' do
    it 'returns expected values' do
      expect(subject.to_params).to eq({
        name: name,
        bankAccountType: bankAccountType,
        routingNumber: routingNumber,
        accountNumber: accountNumber
      })
    end
  end
end
