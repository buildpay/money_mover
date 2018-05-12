module MoneyMover
  module Dwolla
    class ApiResponseMash < Hashie::Mash
      # prevents log when Hashie::Mash runs in to a key that is already a defined method
      # Ex { '_links' => { 'first' => 'some url' } ... }
      disable_warnings

      def embedded_items
        key = _embedded.keys.first
        _embedded[key]
      end
    end

    class BaseResource
      attr_accessor :id, :resource_location
      attr_reader :client, :errors

      ACTIONS = [:list, :find, :create, :update, :destroy]

      class << self
        attr_reader :_list_filters, :_endpoint_paths

        def list_filters(*filter_keys)
          @_list_filters = filter_keys
        end

        def endpoint_path(path, action: [])
          @_endpoint_paths ||= {}
          action.each do |action|
            @_endpoint_paths[action.to_sym] = path if ACTIONS.include?(action.to_sym)
          end
        end
      end

      def initialize(client = ApplicationClient.new)
        @client = client
        @errors = StandaloneErrors.new
      end

      def list(params = {}, *ids)
        path = get_path(:list, ids)

        params = sanitize_list_params(params)
        response = @client.get path, params
        if response.success?
          ApiResponseMash.new(response.body)
        else
          raise "Error fetching #{path} params:#{params} - #{response.errors.full_messages}"
        end
      end

      def find(id)
        path = get_path(:find, [id])

        response = @client.get path

        if response.success?
          ApiResponseMash.new(response.body)
        else
          raise "Error finding #{path} - #{response.errors.full_messages}"
        end
      end

      def create(model, *ids)
        path = get_path(:create, ids)

        errors.clear
        if model.valid?
          response = @client.post path, model.to_params
          if response.success?
            @resource_location = response.resource_location
            @id = response.resource_id
          else
            add_errors_from response
          end
        else
          add_errors_from(model)
        end

        errors.empty?
      end

      def update(model, *ids)
        path = get_path(:update, ids)

        errors.clear
        if model.valid?
          response = @client.post path, model.to_params

          unless response.success?
            add_errors_from response
          end
        else
          add_errors_from(model)
        end

        errors.empty?
      end

      def destroy(*ids)
        path = get_path(:destroy, ids)

        errors.clear
        response = @client.delete path

        unless response.success?
          add_errors_from response
        end
        errors.empty?
      end

      private

      def endpoint_paths
        self.class._endpoint_paths || {}
      end

      def get_path(path_key, ids)
        raise "Unsupported endpoint (#{path_key} path not defined)" unless endpoint_paths.key?(path_key)

        path = endpoint_paths[path_key]
        ids.flatten.compact.each do |id|
          path = path.sub(/:\w*/, id.to_s)
        end

        raise "Expected additional url id parameters #{endpoint_paths[path_key]} - ids:#{ids}"  if path =~ /:\w*/

        path
      end

      def list_filters
        self.class._list_filters || []
      end

      def sanitize_list_params(params)
        params.select {|k, v| list_filters.include?(k) && (v.is_a?(String) || v.is_a?(Integer)) }
      end

      def add_errors_from(source)
        source.errors.each do |key, messages|
          @errors.add key, messages
        end
      end
    end
  end
end
