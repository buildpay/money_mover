require 'spec_helper'

describe MoneyMover::Dwolla::CustomerResource do
  describe 'create unverified customer' do
    let(:firstName) { 'first name' }
    let(:lastName) { 'last name' }
    let(:email) { 'some@example.com' }
    let(:ipAddress) { '127.0.0.1' }

    let(:attrs) {{
      firstName: firstName,
      lastName: lastName,
      email: email,
      ipAddress: ipAddress
    }}

    let(:customer_model) { MoneyMover::Dwolla::UnverifiedCustomer.new(attrs) }
    subject { described_class.new }

    let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }

    let(:create_customer_params) {{
      firstName: firstName,
      lastName: lastName,
      email: email,
      ipAddress: ipAddress,
      type: 'unverified'
    }}

    before do
      dwolla_helper.stub_create_customer_request create_customer_params, create_response
    end

    describe '#create' do
      context 'success' do
        let(:create_response) { dwolla_helper.customer_created_response customer_token }

        it 'creates new customer in dwolla' do
          expect(customer_model.valid?).to eq(true)
          expect(subject.create(customer_model)).to eq(true)
          expect(subject.id).to eq(customer_token)
          expect(subject.resource_location).to eq(dwolla_helper.customer_endpoint(customer_token))
        end
      end

      context 'fail' do
        let(:create_response) { dwolla_helper.resource_create_error_response error_response }

        let(:error_response) {{
          code: "ValidationError",
          message: "Validation error(s) present. See embedded errors list for more details.",
          _embedded: {
            errors: [
              { code: "Duplicate", message: "A customer with the specified email already exists.", path: "/email"
            }
            ]
          }
        }}

        it 'returns errors' do
          expect(subject.create(customer_model)).to eq(false)
          expect(subject.errors[:email]).to eq(['A customer with the specified email already exists.'])
          expect(subject.id).to be_nil
          expect(subject.resource_location).to be_nil
        end
      end
    end
  end
end
