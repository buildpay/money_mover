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
        params = {
          firstName: firstName,
          lastName: lastName,
          title: title,
          dateOfBirth: dateOfBirth,
          ssn: ssn,
          address: address ? address.to_params : nil
        }
        params[:passport] = passport.to_params unless params[:ssn]
        params.compact
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
        :businessClassification,
        :businessType,
        :businessName

      validates_inclusion_of :businessType, in: COMPANY_TYPES, message: "is invalid", if: -> { businessType.present? }

      validates_presence_of :ssn, :dateOfBirth, unless: :controller_required?

      validates_presence_of :ein, if: :controller_required?
      validate :validate_associated_controller, if: :controller_required?

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
          phone: phone,
          address1: address1,
          address2: address2,
          city: city,
          state: state,
          postalCode: postalCode,
          businessClassification: businessClassification,
          businessType: businessType,
          businessName: businessName,
          doingBusinessAs: doingBusinessAs.present? ? doingBusinessAs : businessName, # hack to fix bug on dwolla's side with funding sources being removed if no dba is sent (TODO still a problem?)
          ipAddress: ipAddress,
          type: type
        }

        if controller_required?
          attrs[:ein] = ein
        else  # soleproprietorship
          attrs[:ssn] = ssn
          attrs[:dateOfBirth] = dateOfBirth
        end

        attrs[:controller] = controller.to_params if controller_required? && controller

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
    end
  end
end
