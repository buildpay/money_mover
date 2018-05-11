require 'spec_helper'

describe MoneyMover::Dwolla::CustomerResource do
  describe 'update UnverifiedCustomer' do
    let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }
    let(:firstName) { 'first name' }
    let(:lastName) { 'last name' }
    let(:email) { 'some@example.com' }
    let(:ipAddress) { '127.0.0.1' }

    let(:attrs) {{
      id: customer_token,
      firstName: firstName,
      lastName: lastName,
      email: email,
      ipAddress: ipAddress
    }}

    let(:customer_model) { MoneyMover::Dwolla::UnverifiedCustomer.new(attrs) }
    subject { described_class.new }

    let(:update_customer_params) {{
      firstName: firstName,
      lastName: lastName,
      email: email,
      ipAddress: ipAddress
    }}

    before do
      dwolla_helper.stub_update_customer_request customer_token, update_customer_params, update_response
    end

    describe '#update' do
      context 'success' do
        let(:update_response) do
          {
            status: 200,
            body: ""
          }
        end

        it 'creates new customer in dwolla' do
          expect(subject.update(customer_model, customer_token)).to eq(true)
        end
      end

      context 'fail' do
        let(:update_response) { dwolla_helper.resource_create_error_response error_response }

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
          expect(subject.update(customer_model, customer_token)).to eq(false)
          expect(subject.errors[:email]).to eq(['A customer with the specified email already exists.'])
        end
      end
    end
  end
end
