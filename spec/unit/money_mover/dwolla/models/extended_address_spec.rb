require 'spec_helper'

describe MoneyMover::Dwolla::ExtendedAddress do

  let(:address1) { double 'address1' }
  let(:address2) { double 'address2' }
  let(:address3) { double 'address3' }
  let(:city) { double 'city' }
  let(:stateProvinceRegion) { double 'stateProvinceRegion' }
  let(:postalCode) { double 'postalCode' }
  let(:country) { double 'country' }

  subject { described_class.new(attrs) }

  let(:required_address_attrs) do
    {
      address1: address1,
      city: city,
      stateProvinceRegion: stateProvinceRegion,
      postalCode: postalCode,
      country: country
    }
  end

  let(:complete_address_attrs) do
    required_address_attrs.merge(
      address2: address2,
      address3: address3)
  end

  describe '#valid?' do
    context 'valid' do
      let(:attrs) { required_address_attrs }

      it 'returns true' do
        expect(subject.valid?).to eq(true)
      end
    end

    context 'invalid - missing required attrs' do
      let(:attrs) { {} }

      it 'returns false' do
        expect(subject.valid?).to eq(false)
        expect(subject.errors.full_messages).to eq([
          "Address1 can't be blank",
          "City can't be blank",
          "Stateprovinceregion can't be blank",
          "Postalcode can't be blank",
          "Country can't be blank"
        ])
      end
    end
  end

  describe '#to_params' do
    let(:attrs) { complete_address_attrs }

    it 'returns expected values' do
      expect(subject.to_params).to eq({
        address1: address1,
        address2: address2,
        address3: address3,
        city: city,
        stateProvinceRegion: stateProvinceRegion,
        postalCode: postalCode,
        country: country
      })
    end
  end
end
