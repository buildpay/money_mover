module MoneyMover
  module Dwolla
    class VerifiedBusinessCustomerController < BaseModel
      attr_accessor :firstName, :lastName, :title, :dateOfBirth, :ssn
      attr_reader :passport, :address

      validates_presence_of :firstName, :lastName, :title, :dateOfBirth, :address
      validate :validate_associated_address, if: -> { address.present? }
      validate :validate_ssn_or_passport

      def passport=(attrs={})
        @passport = Passport.new(attrs)
      end

      def address=(attrs={})
        @address = ExtendedAddress.new(attrs)
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
        }.compact
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

    class VerifiedBusinessCustomer < BaseModel
      COMPANY_TYPES = %w( soleproprietorship llc partnership corporation )
      CONTROLER_EXEMPT_BUSINESS_TYPES = ['soleproprietorship']

      attr_accessor :firstName,
        :lastName,
        :email,
        :address1,
        :address2,
        :city,
        :state,
        :postalCode,
        :dateOfBirth,
        :ssn,
        :phone,
        :businessClassification,
        :businessType,
        :businessName,
        :ein,
        :doingBusinessAs,
        :website,
        :ipAddress,
        :status,
        :created
      attr_accessor :controller
      attr_reader :type

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

      validates_inclusion_of :businessType, in: COMPANY_TYPES, message: "is invalid", if: -> { businessType.present? }

      def initialize(attributes={})
        @type = 'business'
        super
      end

      def controller=(attrs={})
        @controller = VerifiedBusinessCustomerController.new(attrs)
      end

      def to_params
        attrs = {
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
          type: type
        }
        attrs[:controller] = controller.to_params if controller

        # hack to fix bug on dwolla's side with funding sources being removed if no dba is sent
        attrs[:doingBusinessAs] = businessName unless doingBusinessAs.present?
        attrs.compact
      end

      private

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

      def website_with_protocol
        return nil unless website.present?

        if website =~ %r{^https?://}
          website
        else
          "http://#{website}"
        end
      end
    end
  end
end
