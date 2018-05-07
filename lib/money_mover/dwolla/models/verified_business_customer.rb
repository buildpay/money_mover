module MoneyMover
  module Dwolla

    class BaseModel
      include ActiveModel::Validations
      include ActiveModel::AttributeAssignment

      def initialize(attributes = {})
        assign_attributes(attributes) if attributes
        super()
      end
    end

    class VerifiedBusinessCustomerControllerAddress < BaseModel
      attr_accessor :address1, :address2, :address3,
        :city, :stateProvinceRegion, :postalCode, :country

      validates_presence_of :address1,
        :city,
        :stateProvinceRegion,
        :postalCode,
        :country

      def to_params
        {
          address1: address1,
          address2: address2,
          address3: address3,
          city: city,
          stateProvinceRegion: stateProvinceRegion,
          postalCode: postalCode,
          country: country
        }#.reject{|_key, val| !val.present? }
      end
    end

    class VerifiedBusinessCustomerControllerPassport < BaseModel
      attr_accessor :number, :country

      validates_presence_of :number, :country

      def to_params
        {
          number: number,
          country: country
        }
      end
    end

    class VerifiedBusinessCustomerController < BaseModel
      attr_accessor :firstName, :lastName, :title, :dateOfBirth, :ssn
      attr_reader :passport, :address

      validates_presence_of :firstName, :lastName, :title, :dateOfBirth, :address
      validate :validate_associated_address, if: -> { address.present? }
      validate :validate_ssn_or_passport

      def passport=(attrs={})
        @passport = VerifiedBusinessCustomerControllerPassport.new(attrs)
      end

      def address=(attrs={})
        @address = VerifiedBusinessCustomerControllerAddress.new(attrs)
      end

      def to_params
        {
          firstName: firstName,
          lastName: lastName,
          title: title,
          dateOfBirth: dateOfBirth,
          ssn: ssn,
          passport: passport ? passport.to_params : nil,
          address: address ? address.to_params : nil
        }.reject{|_key, val| !val.present? }
      end

      private

      def validate_associated_address
        unless address.valid?
          address.errors.full_messages.each do |message|
            errors.add :address, message
          end
        end
      end

      def validate_ssn_or_passport
        unless ssn.present? || (passport.present? && passport.valid?)
          errors.add :base, "SSN or Passport information must be provided"
        end
      end
    end

    class VerifiedBusinessCustomer < Customer
      CONTROLER_EXEMPT_BUSINESS_TYPES = ['soleproprietorship']

      # TODO type should be defined here or in a base class 'VerifiedCustomer' (instead of Customer) (note create_params already defaults it to business
      # attr_accessor :type
      attr_accessor :controller

      validates_presence_of :firstName,
        :lastName,
        :email,
        :address1,
        :city,
        :state,
        :postalCode,
        :dateOfBirth,
        :ssn,
        :phone,
        :businessClassification,
        :businessType,
        :businessName,
        :ein
      validate :validate_associated_controller, if: :controller_required?

      #validates_inclusion_of :businessType, in: COMPANY_TYPES

      def controller=(attrs={})
        @controller = VerifiedBusinessCustomerController.new(attrs)
      end

      private

      def create_params
        create_attrs = {
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
          type: 'business',
          controller: controller.to_params
        }

        # hack to fix bug on dwolla's side with funding sources being removed if no dba is sent
        create_attrs[:doingBusinessAs] = businessName unless doingBusinessAs.present?

        create_attrs.reject{|_key, val| !val.present? }
      end

      def controller_required?
        businessType.present? && !CONTROLER_EXEMPT_BUSINESS_TYPES.include?(businessType.downcase)
      end

      def validate_associated_controller
        if controller.present?
          unless controller.valid?
            controller.errors.full_messages.each do |message|
              errors.add :controller, message
            end
          end
        else
          errors.add :controller, :blank
        end
      end
    end
  end
end
