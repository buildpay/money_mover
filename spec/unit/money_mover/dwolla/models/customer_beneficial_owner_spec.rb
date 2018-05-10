require 'spec_helper'

describe MoneyMover::Dwolla::CustomerBeneficialOwner do
  let(:firstName) { double 'FirstName' }
  let(:lastName) { double 'LastName' }
  let(:dateOfBirth) { double 'DateOfBirth' }
  let(:ssn) { double 'Ssn' } # required if no passport info
  let(:owner_passport_params) { double 'controller passport params' } # require if no ssn
  let(:owner_address_params) { double 'owner address params' }

  let(:passport_valid?) { true }
  let(:passport_to_params) { double 'controller passport to_params' }
  let(:owner_passport) { double 'controller passport', valid?: passport_valid?, to_params: passport_to_params }

  let(:address_valid?) { true }
  let(:address_errors) { double 'address errors', full_messages: ["address error msg", "address error msg2"] }
  let(:address_to_params) { double 'controller passport to_params' }
  let(:owner_address) { double 'controller address', valid?: address_valid?, errors: address_errors, to_params: address_to_params }

  let(:required_owner_attrs) do
    {
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      address: owner_address_params,
      ssn: ssn
    }
  end

  let(:required_owner_attrs_with_passport) do
    {
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      address: owner_address_params,
      passport: owner_passport_params
    }
  end

  before do
    allow(MoneyMover::Dwolla::Passport).to receive(:new).with(owner_passport_params) { owner_passport }
    allow(MoneyMover::Dwolla::ExtendedAddress).to receive(:new).with(owner_address_params) { owner_address }
  end

  subject { described_class.new(attrs) }

  describe '#valid?' do
    context 'valid - with ssn' do
      let(:attrs) { required_owner_attrs }

      it 'returns true' do
        expect(MoneyMover::Dwolla::ExtendedAddress).to receive(:new).with(owner_address_params)
        expect(MoneyMover::Dwolla::Passport).to_not receive(:new)
        expect(owner_address).to receive(:valid?)

        expect(subject.valid?) #.to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'valid - with passport' do
      let(:attrs) { required_owner_attrs_with_passport }

      it 'returns true' do
        expect(owner_passport).to receive(:valid?)
        expect(owner_address).to receive(:valid?)

        expect(subject.valid?).to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'invalid - empty params' do
      let(:attrs) { {} }

      it 'returns false' do
        expect(MoneyMover::Dwolla::ExtendedAddress).to_not receive(:new)
        expect(MoneyMover::Dwolla::Passport).to_not receive(:new)

        expect(subject.valid?).to eq(false)

        expect(subject.errors.full_messages).to eq([
          "Firstname can't be blank",
          "Lastname can't be blank",
          "Dateofbirth can't be blank",
          "Address can't be blank",
          "SSN or Passport information must be provided"
        ])
      end
    end

    context 'invalid - with invalid address' do
      let(:attrs) { required_owner_attrs }
      let(:address_valid?) { false }

      it 'returns false' do
        expect(MoneyMover::Dwolla::Passport).to_not receive(:new)
        expect(owner_address).to receive(:valid?)

        expect(subject.valid?).to eq(false)
        expect(subject.errors.full_messages).to eq([
          'Address address error msg', "Address address error msg2"
        ])
      end
    end

    context 'invalid - with invalid passport' do
      let(:attrs) { required_owner_attrs_with_passport }
      let(:passport_valid?) { false }

      it 'returns false' do
        expect(subject.valid?).to eq(false)
        expect(subject.errors.full_messages).to eq(["SSN or Passport information must be provided"])
      end
    end
  end

  describe '#to_params' do
    context 'all params set' do
      let(:attrs) do
        attrs = required_owner_attrs_with_passport
        attrs[:ssn] = ssn
        attrs
      end

      it 'returns expected values' do

        expect(subject.to_params).to eq({
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          ssn: ssn,
          passport: passport_to_params,
          address: address_to_params
        })
      end
    end

    context 'address and passport NOT set' do
      let(:attrs) do
        attrs = required_owner_attrs
        attrs.delete(:address)
        attrs
      end

      it 'returns expected values' do
        expect(subject.to_params).to eq({
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          ssn: ssn
        })
      end
    end
  end
end
