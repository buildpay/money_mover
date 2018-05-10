require 'spec_helper'

describe MoneyMover::Dwolla::Passport do
  let(:number) { double 'number' }
  let(:country) { double 'country' }
  let(:attrs) do
    {
      number: number,
      country: country
    }
  end

  subject { described_class.new(attrs) }

  it { should validate_presence_of(:number) }
  it { should validate_presence_of(:country) }

  describe '#to_params' do
    it 'returns expected values' do
      expect(subject.to_params).to eq({
        number: number,
        country: country
      })
    end
  end
end
