require 'spec_helper'

describe 'VerifiedBusinessCustomer models' do

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
  let(:ipAddress) { double 'ip address' }


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
      allow(MoneyMover::Dwolla::Passport).to receive(:new).with(controller_passport_params) { controller_passport }
      allow(MoneyMover::Dwolla::ExtendedAddress).to receive(:new).with(controller_address_params) { controller_address }
    end

    describe '#valid?' do
      context 'valid - with ssn' do
        let(:attrs) { required_controller_attrs }

        it 'returns true' do
          expect(MoneyMover::Dwolla::Passport).to_not receive(:new)
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
          expect(MoneyMover::Dwolla::ExtendedAddress).to_not receive(:new)
          expect(MoneyMover::Dwolla::Passport).to_not receive(:new)

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
          expect(MoneyMover::Dwolla::Passport).to_not receive(:new)
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

        it 'returns expected values (excludes passport)' do
          expect(subject.to_params).to eq({
            firstName: controllerFirstName,
            lastName: controllerLastName,
            title: controllerTitle,
            dateOfBirth: controllerDateOfBirth,
            ssn: controllerSsn,
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

    let(:required_soleproprietor_customer_attrs) do
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
        businessClassification: businessClassification,
        businessType: businessType,
        businessName: businessName,
      }
    end

    let(:complete_soleproprietor_customer_attrs) do
      required_soleproprietor_customer_attrs.merge(
        address2: address2,
        phone: phone,
        doingBusinessAs: doingBusinessAs,
        ipAddress: ipAddress
      )
    end

    let(:required_non_soleproprietor_customer_attrs) do
      {
        firstName: firstName,
        lastName: lastName,
        email: email,
        address1: address1,
        city: city,
        state: state,
        postalCode: postalCode,
        businessClassification: businessClassification,
        businessType: businessType,
        businessName: businessName,
        ein: ein
      }
    end

    let(:complete_non_soleproprietor_customer_attrs) do
      required_non_soleproprietor_customer_attrs.merge(
        address2: address2,
        phone: phone,
        doingBusinessAs: doingBusinessAs,
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
      context 'businessType is soleproprietorship (ein and controller NOT required)' do
        let(:businessType) { 'soleproprietorship' }
        let(:required_customer_attrs) { required_soleproprietor_customer_attrs }
        let(:complete_customer_attrs) { complete_soleproprietor_customer_attrs }

        context 'valid - (ein and controller NOT set)' do
          let(:attrs) { required_customer_attrs }

          it 'returns true' do
            expect(MoneyMover::Dwolla::VerifiedBusinessCustomerController).to_not receive(:new)
            expect(subject.valid?).to eq(true)
            expect(subject.errors).to be_empty
          end
        end

        context 'valid - complete set of customer attrs' do
          let(:attrs) { complete_customer_attrs }

          it 'returns true' do
            expect(MoneyMover::Dwolla::VerifiedBusinessCustomerController).to_not receive(:new)
            expect(customer_controller).to_not receive(:valid?)
            expect(subject.valid?).to eq(true)
            expect(subject.errors).to be_empty
          end
        end

        context 'invalid - only businessType is set' do
          let(:attrs) { { businessType: businessType } }

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
              "Businessclassification can't be blank",
              "Businessname can't be blank",
              "Ssn can't be blank",
              "Dateofbirth can't be blank"
            ])
          end
        end
      end

      context 'businessType NOT soleproprietorship (i.e. llc, corporation, partnership)' do
        let(:required_customer_attrs) { required_non_soleproprietor_customer_attrs }
        let(:complete_customer_attrs) { complete_non_soleproprietor_customer_attrs }


        context 'valid - all required fields set' do
          let(:attrs) { required_non_soleproprietor_customer_attrs.merge(controller: controller_params) }

          it 'returns true' do
            expect(customer_controller).to receive(:valid?)
            expect(subject.valid?).to eq(true)
            expect(subject.errors).to be_empty
          end
        end

        context 'valid - complete set of customer attrs and controller' do
          let(:attrs) { complete_customer_attrs.merge(controller: controller_params) }

          it 'returns true' do
            expect(customer_controller).to receive(:valid?)
            expect(subject.valid?).to eq(true)
            expect(subject.errors).to be_empty
          end
        end

        context 'invalid - only businessType is set' do
          let(:attrs) { { businessType: businessType } }

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
              "Businessclassification can't be blank",
              "Businessname can't be blank",
              "Ein can't be blank",
              "Controller can't be blank"
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
            "Businessclassification can't be blank",
            "Businesstype can't be blank",
            "Businessname can't be blank",
            "Ssn can't be blank",
            "Dateofbirth can't be blank"
          ])
        end
      end
    end

    describe '#to_params' do
      context 'businessType is NOT soleproprietor' do
        context 'all fields set' do
          let(:attrs) { complete_non_soleproprietor_customer_attrs.merge(controller: controller_params) }

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
              phone: phone,
              businessClassification: businessClassification,
              businessType: businessType,
              businessName: businessName,
              ein: ein,
              doingBusinessAs: doingBusinessAs,
              ipAddress: ipAddress,
              type: 'business',
              controller: controller_to_params
            })
          end
        end

        context 'controller not set' do
          let(:attrs) { required_non_soleproprietor_customer_attrs }

          it 'returns expected values' do
            expect(subject.to_params).to eq({
              firstName: firstName,
              lastName: lastName,
              email: email,
              address1: address1,
              city: city,
              state: state,
              postalCode: postalCode,
              businessClassification: businessClassification,
              businessType: businessType,
              businessName: businessName,
              ein: ein,
              doingBusinessAs: businessName,
              type: 'business'
            })
          end
        end
      end

      context 'businessType is soleproprietor' do
        let(:businessType) { 'soleproprietorship' }

        context 'complete data set' do
          let(:attrs) { complete_soleproprietor_customer_attrs.merge(controller: controller_params) }

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
              phone: phone,
              businessClassification: businessClassification,
              businessType: businessType,
              businessName: businessName,
              dateOfBirth: dateOfBirth,
              ssn: ssn,
              doingBusinessAs: doingBusinessAs,
              ipAddress: ipAddress,
              type: 'business',
            })
          end
        end

        context 'required data set' do
          let(:attrs) { required_soleproprietor_customer_attrs.merge(controller: controller_params) }

          it 'returns expected values' do
            expect(subject.to_params).to eq({
              firstName: firstName,
              lastName: lastName,
              email: email,
              address1: address1,
              city: city,
              state: state,
              postalCode: postalCode,
              businessClassification: businessClassification,
              businessType: businessType,
              businessName: businessName,
              dateOfBirth: dateOfBirth,
              ssn: ssn,
              doingBusinessAs: businessName,
              type: 'business',
            })
          end
        end
      end
    end
  end
end
