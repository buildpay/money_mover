require 'spec_helper'

describe MoneyMover::Dwolla::CustomerBeneficialOwnerResource do
  let(:firstName) { 'Joe' }
  let(:lastName) { 'Smith' }
  let(:dateOfBirth) { '1990-05-10' }
  let(:ssn) { '1234' }

  let(:attrs) do
    {
      firstName: 'Joe',
      lastName: 'Smith',
      dateOfBirth: '1988-05-10',
      ssn: '444551234',
      address: {
        address1: '123 Sesame Street',
        address2: 'Suite 201',
        address3: 'c/o William',
        city: 'Saint Louis',
        stateProvinceRegion: 'MO',
        postalCode: '63141',
        country: 'US'
      }
    }
  end

  let(:customer_beneficial_owner_model) { MoneyMover::Dwolla::CustomerBeneficialOwner.new(attrs) }

  subject { described_class.new }

  let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }
  let(:beneficial_owner_token) { 'FC451A7A-AE30-4404-AB95-E3553FCD733F' }

  let(:create_params) do
    {
      firstName: 'Joe',
      lastName: 'Smith',
      dateOfBirth: '1988-05-10',
      ssn: '444551234',
      address: {
        address1: '123 Sesame Street',
        address2: 'Suite 201',
        address3: 'c/o William',
        city: 'Saint Louis',
        stateProvinceRegion: 'MO',
        postalCode: '63141',
        country: 'US'
      }
    }
  end

  before do
    dwolla_helper.stub_create_customer_beneficial_owner_request customer_token, create_params, create_response
  end

  describe '#create' do
    context 'valid' do
      let(:create_response) { dwolla_helper.customer_beneficial_owner_created_response(customer_token, beneficial_owner_token) }

      it 'creates new customer beneficial owner in dwolla' do
        expect(subject.create(customer_beneficial_owner_model, customer_token)).to eq(true)
        expect(subject.id).to eq(beneficial_owner_token)
        expect(subject.resource_location).to eq(dwolla_helper.customer_beneficial_owner_endpoint(customer_token, beneficial_owner_token))
      end
    end

    context 'invalid' do
      let(:create_response) do
        dwolla_helper.error_response(
          code: "ValidationError",
          message: "Validation error(s) present. See embedded errors list for more details.",
          _embedded: {
            errors: [
              {
                code: "Invalid",
                message: "Invalid parameter.",
                path: "/address"
              }
            ]
          }
        )
      end

      it 'returns false and sets errors' do
        expect(subject.create(customer_beneficial_owner_model, customer_token)).to eq(false)
        expect(subject.errors[:address]).to eq(['Invalid parameter.'])
        expect(subject.id).to be_nil
        expect(subject.resource_location).to be_nil
      end
    end
  end
end
