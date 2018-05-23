module MoneyMover
  module Dwolla
    class CustomerTransferResource < BaseResource
      list_filters :search,
        :startAmount,
        :endAmount,
        :startDate,
        :endDate,
        :status,
        :correlationId,
        :limit,
        :offset
      endpoint_path '/customers/:customer_id/transfers', action: [:list]
      endpoint_path '/transfers', action: [:create]
      endpoint_path '/transfers/:id', action: [:find]

      def cancel_transfer(id)
        path = get_path(:find, [id])

        errors.clear
        response = client.post path, { status: 'cancelled' }
        unless response.success?
          add_errors_from response
        end

        errors.empty?
      end

      def get_failure_reason(id)
        path = "#{get_path(:find, [id])}/failure"

        response = client.get path

        if response.success?
          ApiResponseMash.new(response.body)
        else
          raise "Error finding #{path} - #{response.errors.full_messages}"
        end
      end
    end
  end
end
