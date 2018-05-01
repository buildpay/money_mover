require 'spec_helper'

describe MoneyMover::Dwolla::VerifiedBusinessCustomer do
  let(:firstName) { double 'first name' }
  let(:lastName) { double 'last name' }
  let(:email) { double 'email' }
  let(:address1) { double 'address 1' }
  let(:address2) { double 'address 2' }
  let(:city) { double 'city' }
  let(:state) { double 'state' }
  let(:postalCode) { double 'postal code' }
  let(:dateOfBirth) { double 'dob' }
  let(:ssn) { double 'ssn' }
  let(:phone) { double 'phone' }
  let(:businessClassification) { double 'business classification' }
  let(:businessType) { 'soleProprietorship' } # default to case where controller is not required. Note capitalization to make sure downcase is called.
  let(:businessName) { double 'business name' }
  let(:ein) { double 'ein' }
  let(:doingBusinessAs) { double 'dba' }
  let(:website) { 'www.buildpay.co' }
  let(:ipAddress) { double 'ip address' }

  # controller fields (required if businessType != 'soleproprietorship')
  let(:controllerFirstName) { double 'controllerFirstName' }
  let(:controllerLastName) { double 'controllerLastName' }
  let(:controllerTitle) { double 'controllerTitle' }
  let(:controllerDateOfBirth) { double 'controllerDateOfBirth' }
  let(:controllerAddress1) { double 'controllerAddress1' }
  let(:controllerCity) { double 'controllerCity' }
  let(:controllerState) { double 'controllerState' }
  let(:controllerPostalCode) { double 'controllerPostalCode' }
  let(:controllerCountry) { double 'controllerCountry' }
  # controller optionally required fields (ssn or passport info)
  let(:controllerSsn) { double 'controllerSsn' }
  let(:controllerPassportNumber) { double 'controllerPassportNumber' }
  let(:controllerPassportCountry) { double 'controllerPassportCountry' }

  # optional controller fields
  let(:controllerAddress2) { double 'controllerAddress2' }
  let(:controllerAddress3) { double 'controllerAddress3' }

  # TODO: add test for not being able to set type, status, created, etc. directly...

  let(:account_client) { double 'account client' }

  subject { described_class.new attrs, account_client }



  describe '#save' do
    let(:required_attrs) {{
      firstName: firstName,
      lastName: lastName,
      email: email,
      address1: address1,
      city: city,
      state: state,
      postalCode: postalCode,
      dateOfBirth: dateOfBirth,
      ssn: ssn,
      phone: phone,
      businessClassification: businessClassification,
      businessType: businessType,
      businessName: businessName,
      ein: ein
    }}

    let(:required_controller_attrs) {{
      controllerFirstName: controllerFirstName,
      controllerLastName: controllerLastName,
      controllerTitle: controllerTitle,
      controllerDateOfBirth: controllerDateOfBirth,
      controllerSsn: controllerSsn,
      controllerAddress1: controllerAddress1,
      controllerCity: controllerCity,
      controllerState: controllerState,
      controllerPostalCode: controllerPostalCode,
      controllerCountry: controllerCountry
    }}

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
      website: website,
      ipAddress: ipAddress
    }}

    let(:create_customer_params) {{
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
      website: website_with_protocol,
      ipAddress: ipAddress,
      type: 'business'
    }}

    let(:website_with_protocol) { "http://#{website}" }

    let(:dwolla_response) { double 'dwolla response', success?: success?, resource_id: resource_id, resource_location: resource_location, errors: dwolla_errors }
    let(:resource_id) { double 'resource id' }
    let(:resource_location) { double 'resource location' }
    let(:dwolla_errors) {{
      errorKey1: 'some error 1',
      errorKey2: 'some error 2'
    }}

    let(:create_endpoint) { "/customers" }

    before do
      allow(account_client).to receive(:post).with(create_endpoint, create_customer_params) { dwolla_response }
    end

    shared_examples 'resource created successfully' do
      it 'returns true' do

        expect(subject.save).to eq(true)
        expect(subject.errors.count).to eq(0)

        expect(subject.id).to eq(resource_id)
        expect(subject.resource_location).to eq(resource_location)
      end
    end

    context 'success' do
      let(:success?) { true }

      it_behaves_like "resource created successfully"


      context 'only required fields sent' do
        let(:attrs) { required_attrs }

        let(:create_customer_params) {{
          firstName: firstName,
          lastName: lastName,
          email: email,
          address1: address1,
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
          doingBusinessAs: businessName,
          type: 'business'
        }}

        it_behaves_like "resource created successfully"
      end

      context 'sending empty strings for non-required fields' do
        let(:attrs) { required_attrs.merge(address2: '', doingBusinessAs: '', website: '', ipAddress: '') }

        let(:create_customer_params) {{
          firstName: firstName,
          lastName: lastName,
          email: email,
          address1: address1,
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
          doingBusinessAs: businessName,
          type: 'business'
        }}

        it_behaves_like "resource created successfully"
      end

      context 'using https for website protocol' do
        let(:website) { 'https://something.com' }
        let(:website_with_protocol) { 'https://something.com' }

        it_behaves_like "resource created successfully"
      end

      context 'business type is not "soleproprietor"' do
        let(:businessType) { 'partnership' }


        let(:required_attrs_with_controller) { required_attrs.merge(required_controller_attrs) }

        let(:required_create_customer_params_with_controller) {{
            firstName: firstName,
            lastName: lastName,
            email: email,
            address1: address1,
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
            doingBusinessAs: businessName,
            type: 'business',
            controller: {
              firstName: controllerFirstName,
              lastName: controllerLastName,
              title: controllerTitle,
              dateOfBirth: controllerDateOfBirth,
              ssn: controllerSsn,
              address: {
                address1: controllerAddress1,
                city: controllerCity,
                state: controllerState,
                postalCode: controllerPostalCode,
                country: controllerCountry
              }
            }
        }}

        context 'required fields sent' do
          let(:attrs) { required_attrs_with_controller }

          let(:create_customer_params) { required_create_customer_params_with_controller }

          it_behaves_like "resource created successfully"
        end

        context 'required fields sent - controller passport number and country in lieu of SSN' do
          let(:attrs) do
            _attrs = required_attrs_with_controller
            _attrs.delete(:controllerSsn)
            _attrs.merge(controllerPassportNumber: controllerPassportNumber, controllerPassportCountry: controllerPassportCountry)
          end

          let(:create_customer_params) do
            _params = required_create_customer_params_with_controller
            _params[:controller].delete(:ssn)
            _params[:controller][:passport] = { number: controllerPassportNumber, country: controllerPassportCountry }
            _params
          end

          it_behaves_like "resource created successfully"
        end

        context 'required and optional fields set' do
          let(:attrs) { required_attrs_with_controller.merge(controllerAddress2: controllerAddress2, controllerAddress3: controllerAddress3) }

          let(:create_customer_params) do
            _params = required_create_customer_params_with_controller
            _params[:controller][:address][:address2] = controllerAddress2
            _params[:controller][:address][:address3] = controllerAddress3
            _params
          end

          it_behaves_like "resource created successfully"
        end
      end
    end

    context 'invalid' do
      context 'required params not set' do
        let(:attrs) { {} }

        it 'returns errors' do
          expect(account_client).to_not receive(:post)

          expect(subject.save).to eq(false)

          expect(subject.errors.count).to eq(required_attrs.keys.length)
          required_attrs.keys.each do |key|
            expect(subject.errors[key]).to eq(["can't be blank"]), "key:#{key}"
          end
          expect(subject.id).to be_nil
          expect(subject.resource_location).to be_nil
        end
      end

      context 'business type != "soleproprietorship" and required controller fields not set' do
        let(:businessType) { 'llc'}

        it 'returns errors' do
          expect(account_client).to_not receive(:post)

          expect(subject.save).to eq(false)

          expect(subject.errors.count).to eq(required_controller_attrs.keys.length)
          required_controller_attrs.keys.select{|v| v != :controllerSsn}.each do |key|
            expect(subject.errors[key]).to eq(["can't be blank"]), "key:#{key}"
          end
          expect(subject.errors[:base]).to eq(["Controller SSN or Passport information must be provided"])
          expect(subject.id).to be_nil
          expect(subject.resource_location).to be_nil
        end
      end
    end

    context 'fail' do
      let(:success?) { false }

      it 'returns errors' do
        expect(subject.save).to eq(false)

        expect(subject.errors[:errorKey1]).to eq(['some error 1'])
        expect(subject.errors[:errorKey2]).to eq(['some error 2'])

        expect(subject.id).to be_nil
        expect(subject.resource_location).to be_nil
      end
    end
  end
end
