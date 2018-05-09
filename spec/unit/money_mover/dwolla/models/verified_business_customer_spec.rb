require 'spec_helper'

describe 'VerifiedBusinessCustomer models' do

  # Controller address
  let(:controllerAddress1) { double 'controllerAddress1' }
  let(:controllerAddress2) { double 'controllerAddress2' }
  let(:controllerAddress3) { double 'controllerAddress3' }
  let(:controllerCity) { double 'controllerCity' }
  let(:controllerState) { double 'controllerState' }
  let(:controllerPostalCode) { double 'controllerPostalCode' }
  let(:controllerCountry) { double 'controllerCountry' }

  # Controller passport
  let(:controllerPassportNumber) { double 'controllerPassportNumber' }
  let(:controllerPassportCountry) { double 'controllerPassportCountry' }

  let(:passport_attrs) do
    { number: controllerPassportNumber, country: controllerPassportCountry }
  end

  # Controller
  let(:controllerFirstName) { double 'controllerFirstName' }
  let(:controllerLastName) { double 'controllerLastName' }
  let(:controllerTitle) { double 'controllerTitle' }
  let(:controllerDateOfBirth) { double 'controllerDateOfBirth' }
  let(:controllerSsn) { double 'controllerSsn' } # required if no passport info


  # Customer
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
  let(:businessType) { 'llc' } # default to case where controller is required.
  let(:businessName) { double 'business name' }
  let(:ein) { double 'ein' }
  let(:doingBusinessAs) { double 'dba' }
  let(:website) { 'www.buildpay.co' } # default to needing 'http://' prepended
  let(:ipAddress) { double 'ip address' }


  describe MoneyMover::Dwolla::VerifiedBusinessCustomerControllerAddress do
    subject { described_class.new(attrs) }

    let(:required_controller_address_attrs) do
      {
        address1: controllerAddress1,
        city: controllerCity,
        stateProvinceRegion: controllerState,
        postalCode: controllerPostalCode,
        country: controllerCountry
      }
    end

    let(:complete_controller_address_attrs) do
      required_controller_address_attrs.merge(
        address2: controllerAddress2,
        address3: controllerAddress3)
    end

    describe '#valid?' do
      context 'valid' do
        let(:attrs) { required_controller_address_attrs }

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
      let(:attrs) { complete_controller_address_attrs }

      it 'returns expected values' do
        expect(subject.to_params).to eq({
          address1: controllerAddress1,
          address2: controllerAddress2,
          address3: controllerAddress3,
          city: controllerCity,
          stateProvinceRegion: controllerState,
          postalCode: controllerPostalCode,
          country: controllerCountry
        })
      end
    end
  end

  describe MoneyMover::Dwolla::VerifiedBusinessCustomerControllerPassport do
    subject { described_class.new(attrs) }

    describe '#valid?' do
      context 'valid' do
        let(:attrs) { passport_attrs }

        it 'returns true' do
          expect(subject.valid?).to eq(true)
        end
      end

      context 'invalid' do
        let(:attrs) { {} }

        it 'returns false' do
          expect(subject.valid?).to eq(false)
          expect(subject.errors.full_messages).to eq([
            "Number can't be blank",
            "Country can't be blank"
          ])
        end
      end
    end

    describe '#to_params' do
      let(:attrs) { passport_attrs }

      it 'returns expected values' do
        expect(subject.to_params).to eq({
          number: controllerPassportNumber,
          country: controllerPassportCountry
        })
      end
    end
  end

  describe MoneyMover::Dwolla::VerifiedBusinessCustomerController do
    subject { described_class.new(attrs) }


    let(:controller_passport_params) { double 'controller passport params' } # require if no ssn
    let(:controller_address_params) { double 'controller address params' }
    let(:required_controller_attrs) do
      {
        firstName: controllerFirstName,
        lastName: controllerLastName,
        title: controllerTitle,
        dateOfBirth: controllerDateOfBirth,
        address: controller_address_params,
        ssn: controllerSsn
      }
    end
    let(:required_controller_attrs_with_passport) do
      {
        firstName: controllerFirstName,
        lastName: controllerLastName,
        title: controllerTitle,
        dateOfBirth: controllerDateOfBirth,
        address: controller_address_params,
        passport: controller_passport_params
      }
    end

    let(:passport_valid?) { true }
    let(:passport_to_params) { double 'controller passport to_params' }
    let(:controller_passport) { double 'controller passport', valid?: passport_valid?, to_params: passport_to_params }

    let(:address_valid?) { true }
    let(:address_errors) { double 'address errors', full_messages: ["address error msg", "address error msg2"] }
    let(:address_to_params) { double 'controller passport to_params' }
    let(:controller_address) { double 'controller address', valid?: address_valid?, errors: address_errors, to_params: address_to_params }

    before do
      allow(MoneyMover::Dwolla::VerifiedBusinessCustomerControllerPassport).to receive(:new).with(controller_passport_params) { controller_passport }
      allow(MoneyMover::Dwolla::VerifiedBusinessCustomerControllerAddress).to receive(:new).with(controller_address_params) { controller_address }
    end

    describe '#valid?' do
      context 'valid - with ssn' do
        let(:attrs) { required_controller_attrs }

        it 'returns true' do
          expect(MoneyMover::Dwolla::VerifiedBusinessCustomerControllerPassport).to_not receive(:new)
          expect(controller_address).to receive(:valid?)

          expect(subject.valid?).to eq(true)
          expect(subject.errors).to be_empty
        end
      end

      context 'valid - with passport' do
        let(:attrs) { required_controller_attrs_with_passport }

        it 'returns true' do
          expect(controller_passport).to receive(:valid?)
          expect(controller_address).to receive(:valid?)

          expect(subject.valid?).to eq(true)
          expect(subject.errors).to be_empty
        end
      end

      context 'invalid - empty params' do
        let(:attrs) { {} }

        it 'returns false' do
          expect(MoneyMover::Dwolla::VerifiedBusinessCustomerControllerAddress).to_not receive(:new)
          expect(MoneyMover::Dwolla::VerifiedBusinessCustomerControllerPassport).to_not receive(:new)

          expect(subject.valid?).to eq(false)

          expect(subject.errors.full_messages).to eq([
            "Firstname can't be blank",
            "Lastname can't be blank",
            "Title can't be blank",
            "Dateofbirth can't be blank",
            "Address can't be blank",
            "SSN or Passport information must be provided"
          ])
        end
      end

      context 'invalid - with invalid address' do
        let(:attrs) { required_controller_attrs }
        let(:address_valid?) { false }

        it 'returns false' do
          expect(MoneyMover::Dwolla::VerifiedBusinessCustomerControllerPassport).to_not receive(:new)
          expect(controller_address).to receive(:valid?)

          expect(subject.valid?).to eq(false)
          expect(subject.errors.full_messages).to eq([
            'Address address error msg', "Address address error msg2"
          ])
        end
      end

      context 'invalid - with invalid passport' do
        let(:attrs) { required_controller_attrs_with_passport }
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
          attrs = required_controller_attrs_with_passport
          attrs[:ssn] = controllerSsn
          attrs
        end

        it 'returns expected values' do

          expect(subject.to_params).to eq({
            firstName: controllerFirstName,
            lastName: controllerLastName,
            title: controllerTitle,
            dateOfBirth: controllerDateOfBirth,
            ssn: controllerSsn,
            passport: passport_to_params,
            address: address_to_params
          })
        end
      end

      context 'address and passport NOT set' do
        let(:attrs) do
          attrs = required_controller_attrs
          attrs.delete(:address)
          attrs
        end

        it 'returns expected values' do
          expect(subject.to_params).to eq({
            firstName: controllerFirstName,
            lastName: controllerLastName,
            title: controllerTitle,
            dateOfBirth: controllerDateOfBirth,
            ssn: controllerSsn,
          })
        end
      end
    end
  end

  describe MoneyMover::Dwolla::VerifiedBusinessCustomer do
    subject { described_class.new(attrs) }

    let(:required_customer_attrs) do
      {
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
      }
    end

    let(:complete_customer_attrs) do
      required_customer_attrs.merge(
        address2: address2,
        doingBusinessAs: doingBusinessAs,
        website: website,
        ipAddress: ipAddress
      )
    end

    let(:controller_params) { double 'customer controller params' }
    let(:controller_valid?) { true }
    let(:controller_errors) { double 'customer controller errors', full_messages: ["controller error message", "controller error message 2"]}
    let(:controller_to_params) { double 'cusomter controller to_params' }
    let(:customer_controller) { double 'customer controller', valid?: controller_valid?, errors: controller_errors, to_params: controller_to_params }
    before do
      allow(MoneyMover::Dwolla::VerifiedBusinessCustomerController).to receive(:new).with(controller_params) { customer_controller }
    end

    describe '#valid?' do
      context 'valid - businessType soleproprietorhip (no controller required nor set)' do
        let(:attrs) { required_customer_attrs }
        let(:businessType) { 'soleproprietorship' }

        it 'returns true' do
          expect(MoneyMover::Dwolla::VerifiedBusinessCustomerController).to_not receive(:new)
          expect(subject.valid?).to eq(true)
          expect(subject.errors).to be_empty
        end
      end

      context 'valid - businessType soleproprietorhip (no controller required but it is set)' do
        let(:attrs) { required_customer_attrs.merge(controller: controller_params) }
        let(:businessType) { 'soleproprietorship' }

        it 'returns true' do
          expect(MoneyMover::Dwolla::VerifiedBusinessCustomerController).to receive(:new)
          expect(customer_controller).to_not receive(:valid?)
          expect(subject.valid?).to eq(true)
          expect(subject.errors).to be_empty
        end
      end

      context 'valid - all required fields set' do
        let(:attrs) { required_customer_attrs.merge(controller: controller_params) }

        it 'returns true' do
          expect(customer_controller).to receive(:valid?)
          expect(subject.valid?).to eq(true)
          expect(subject.errors).to be_empty
        end
      end

      context 'valid - all fields set' do
        let(:attrs) { complete_customer_attrs.merge(controller: controller_params) }

        it 'returns true' do
          expect(customer_controller).to receive(:valid?)
          expect(subject.valid?).to eq(true)
          expect(subject.errors).to be_empty
        end
      end

      context 'invalid - empty set of params' do
        let(:attrs) { {} }

        it 'returns false' do
          expect(MoneyMover::Dwolla::VerifiedBusinessCustomerController).to_not receive(:new)
          expect(subject.valid?).to eq(false)
          expect(subject.errors.full_messages).to eq([
            "Firstname can't be blank",
            "Lastname can't be blank",
            "Email can't be blank",
            "Address1 can't be blank",
            "City can't be blank",
            "State can't be blank",
            "Postalcode can't be blank",
            "Dateofbirth can't be blank",
            "Ssn can't be blank",
            "Phone can't be blank",
            "Businessclassification can't be blank",
            "Businesstype can't be blank",
            "Businessname can't be blank",
            "Ein can't be blank"
          ])
        end
      end

      context 'invalid - controller is invalid' do
        let(:attrs) { required_customer_attrs.merge(controller: controller_params) }
        let(:controller_valid?) { false }

        it 'returns false' do
          expect(customer_controller).to receive(:valid?)
          expect(subject.valid?).to eq(false)
          expect(subject.errors.full_messages).to eq([
            "Controller controller error message",
            "Controller controller error message 2",
          ])
        end
      end
    end

    describe '#to_params' do
      context 'controller set' do
        let(:attrs) { complete_customer_attrs.merge(controller: controller_params) }

        it 'returns expected values' do
          expect(subject.to_params).to eq({
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
            website: "http://#{website}",  # note adds protocol scheme
            ipAddress: ipAddress,
            type: 'business',
            controller: controller_to_params
          })
        end
      end

      context 'controller not set' do
        let(:attrs) { complete_customer_attrs }

        it 'returns expected values' do
          expect(subject.to_params).to eq({
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
            website: "http://#{website}",  # note adds protocol scheme
            ipAddress: ipAddress,
            type: 'business'
          })
        end
      end

      context 'website has a protocol scheme' do
        let(:website) { "https://somedomain.org" }
        let(:attrs) { complete_customer_attrs }

        it 'returns original website value' do
          expect(subject.to_params[:website]).to eq(website)
        end
      end
    end
  end
end
