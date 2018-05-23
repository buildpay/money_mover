require 'spec_helper'

describe MoneyMover::Dwolla::CustomerResource do
  describe 'create VerifiedBusinessCustomer' do
    let(:firstName) { 'first name' }
    let(:lastName) { 'last name' }
    let(:email) { 'some@example.com' }
    let(:address1) { '123 Anywhere St.' }
    let(:address2) { 'Suite 200' }
    let(:city) { 'St. Louis' }
    let(:state) { 'MO' }
    let(:postalCode) { '63104' }
    let(:dateOfBirth) { '01/28/1970' }
    let(:ssn) { '123456789' }
    let(:phone) { '636-333-3333' }
    let(:businessClassification) { 'some-business-classification' }
    let(:businessType) { 'soleproprietorship' } # Case where Controller info is not required
    let(:businessName) { 'Some Company, LLC' }
    let(:ein) { '987654321' }
    let(:doingBusinessAs) { 'Alternate Company Name' }
    let(:ipAddress) { '127.0.0.1' }

    let(:controller_ssn) { 'controller ssn' }
    let(:controller_params) do
      {
        firstName: 'controller firstname',
        lastName: 'controller lastname',
        title: 'controller title',
        dateOfBirth: 'controller dob',
        address: {
          address1: 'controller address1',
          address2: 'controller address2',
          address3: 'controller address3',
          city: 'controller city',
          stateProvinceRegion: 'controller stateProvinceRegion',
          postalCode: 'controller postalCode',
          country: 'controller country'
        },
        ssn: controller_ssn,
        passport: {
          number: 'controller passport number',
          country: 'controller passport country'
        }
      }
    end

    # TODO: add test for not being able to set type, status, created, etc. directly...

    subject { described_class.new }

    describe '#create' do
      let(:attrs) {{
        firstName: firstName,
        lastName: lastName,
        email: email,
        address1: address1,
        address2: address2,
        city: city,
        state: state,
        postalCode: postalCode,
        dateOfBirth: dateOfBirth,
        ssn: ssn,
        phone: phone,
        businessClassification: businessClassification,
        businessType: businessType,
        businessName: businessName,
        ein: ein,
        doingBusinessAs: doingBusinessAs,
        ipAddress: ipAddress,
        controller: controller_params
      }}

      before do
        dwolla_helper.stub_create_customer_request create_customer_params, create_response
      end

      let(:customer_model) { MoneyMover::Dwolla::VerifiedBusinessCustomer.new(attrs) }


      shared_examples 'handles dwolla api errors' do
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

      context "businessType is 'soleproprietorship'" do
        let(:create_customer_params) do
          {
            firstName: firstName,
            lastName: lastName,
            email: email,
            address1: address1,
            address2: address2,
            city: city,
            state: state,
            postalCode: postalCode,
            phone: phone,
            businessClassification: businessClassification,
            businessType: businessType,
            businessName: businessName,
            doingBusinessAs: doingBusinessAs,
            ipAddress: ipAddress,
            type: 'business',
            ssn: ssn,
            dateOfBirth: dateOfBirth
          }
        end

        context 'success' do
          let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }

          let(:create_response) { dwolla_helper.customer_created_response customer_token }

          it 'creates new customer in dwolla' do
            expect(subject.create(customer_model)).to eq(true)

            expect(subject.id).to eq(customer_token)
            expect(subject.resource_location).to eq(dwolla_helper.customer_endpoint(customer_token))
          end
        end

        context 'fail - model validations before dwolla call' do
          let(:attrs) { { businessType: businessType } }

          let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }
          let(:create_response) { dwolla_helper.customer_created_response customer_token }

          it 'returns errors' do
            expect(subject.create(customer_model)).to eq(false)
            expect(subject.errors.to_a).to eq([
              "Firstname can't be blank",
              "Lastname can't be blank",
              "Email can't be blank",
              "Address1 can't be blank",
              "City can't be blank",
              "State can't be blank",
              "Postalcode can't be blank",
              "Businessclassification can't be blank",
              "Businessname can't be blank",
              "Ssn can't be blank",
              "Dateofbirth can't be blank"
            ])
          end
        end

        it_behaves_like 'handles dwolla api errors'
      end

      context "businessType is NOT 'soleproprietorship' (requires controller and ein)" do
        let(:businessType) { 'llc' }

        let(:create_customer_params) do
          {
            firstName: firstName,
            lastName: lastName,
            email: email,
            address1: address1,
            address2: address2,
            city: city,
            state: state,
            postalCode: postalCode,
            phone: phone,
            businessClassification: businessClassification,
            businessType: businessType,
            businessName: businessName,
            doingBusinessAs: doingBusinessAs,
            ipAddress: ipAddress,
            type: 'business',
            ein: ein,
            controller: create_controller_params
          }
        end

        context 'controller ssn is provided (no passport info should be sent to dwolla)' do
          let(:create_controller_params) do
            p = controller_params.dup
            p.delete(:passport)
            p
          end

          context 'success' do
            let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }

            let(:create_response) { dwolla_helper.customer_created_response customer_token }

            it 'creates new customer in dwolla' do
              expect(subject.create(customer_model)).to eq(true)

              expect(subject.id).to eq(customer_token)
              expect(subject.resource_location).to eq(dwolla_helper.customer_endpoint(customer_token))
            end
          end

          context 'fail - model validations before dwolla call' do
            let(:attrs) { { businessType: businessType } }

            let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }
            let(:create_response) { dwolla_helper.customer_created_response customer_token }

            it 'returns errors' do
              expect(subject.create(customer_model)).to eq(false)
              expect(subject.errors.to_a).to eq([
                "Firstname can't be blank",
                "Lastname can't be blank",
                "Email can't be blank",
                "Address1 can't be blank",
                "City can't be blank",
                "State can't be blank",
                "Postalcode can't be blank",
                "Businessclassification can't be blank",
                "Businessname can't be blank",
                "Ein can't be blank",
                "Controller can't be blank"
              ])
            end
          end

          it_behaves_like 'handles dwolla api errors'
        end

        context 'controller ssn is NOT provided (should send passport info to dwolla)' do
          let(:create_controller_params) do
            p = controller_params
            p.delete(:ssn)
            p
          end

          context 'success' do
            let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }

            let(:create_response) { dwolla_helper.customer_created_response customer_token }

            it 'creates new customer in dwolla' do
              expect(subject.create(customer_model)).to eq(true)

              expect(subject.id).to eq(customer_token)
              expect(subject.resource_location).to eq(dwolla_helper.customer_endpoint(customer_token))
            end
          end

          context 'fail - model validations before dwolla call' do
            let(:attrs) { { businessType: businessType } }

            let(:customer_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }
            let(:create_response) { dwolla_helper.customer_created_response customer_token }

            it 'returns errors' do
              expect(subject.create(customer_model)).to eq(false)
              expect(subject.errors.to_a).to eq([
                "Firstname can't be blank",
                "Lastname can't be blank",
                "Email can't be blank",
                "Address1 can't be blank",
                "City can't be blank",
                "State can't be blank",
                "Postalcode can't be blank",
                "Businessclassification can't be blank",
                "Businessname can't be blank",
                "Ein can't be blank",
                "Controller can't be blank"
              ])
            end
          end

          it_behaves_like 'handles dwolla api errors'
        end
      end
    end
  end
end
