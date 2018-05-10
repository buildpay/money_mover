RSpec.shared_context "shared base resource setup" do
  let(:response_body) { double 'response body' }
  let(:error_messages) { ["error message1", "error message2"] }
  let(:response_errors) { double 'response errors', full_messages: error_messages }
  let(:response_success?) { true }
  let(:resource_location) { double 'resource_location header' }
  let(:resource_id) { double 'resource_id from location header' }
  let(:client_response) do
    double 'ApiServerResponse from client',
      body: response_body,
      errors: response_errors,
      success?: response_success?,
      resource_location: resource_location,
      resource_id: resource_id
  end
  let(:client) { double 'ApplicationClient', get: client_response, post: client_response, delete: client_response }
  let(:response_mash) { double 'Hash::Mash created from response body' }

  before do
    allow(MoneyMover::Dwolla::ApplicationClient).to receive(:new) { client }
    allow(MoneyMover::Dwolla::ApiResponseMash).to receive(:new) { response_mash }
  end
end

shared_examples_for 'base resource list' do
  # TO BE SET BY SPEC
  # let(:id) { nil }  # if no id needed for list url
  #   OR let(:id) { 123 } # if id is required
  #   OR let(:id) { [123, 456] } if multiple route ids
  # let(:expected_path) { '/customers/123/funding-sources' }
  # let(:valid_filter_params) { [:search, :status, :limit, :offset ] }

  include_context 'shared base resource setup'

  describe '#list' do
    let(:params) { {} } # default to no filter params

    context 'success' do
      let(:response_success?) { true }
      let(:expected_filter_params) { {} }

      it 'makes expected call and returns expected response' do
        expect(client).to receive(:get).with(expected_path, expected_filter_params)

        expect(subject.list(params, id)).to eq(response_mash)
      end
    end

    context 'success - with filter params' do
      let(:params) do
        p = {}
        valid_filter_params.each_with_index do |key, idx|
          p[key]="#{key}_val_#{idx}"
        end
        p[:invalidkey] = "value_to_be_filtered_out"
        p
      end

      let(:expected_filter_params) do
        p = params.dup
        p.delete(:invalidkey)
        p
      end

      it 'makes expected call with correct querystring' do
        expect(client).to receive(:get).with(expected_path, expected_filter_params)

        expect(subject.list(params, id)).to eq(response_mash)
      end
    end

    context 'failure' do
      let(:response_success?) { false }

      it 'raises error' do
        expect(client).to receive(:get).with(expected_path, params)

        expect{ subject.list(params, id) }.to raise_error("Error while fetching #{expected_path} params:#{params} - #{error_messages}")
      end
    end
  end
end

shared_examples_for 'base resource find' do
  # TO BE SET BY SPEC
  #let(:id) { 777 }
  #let(:expected_path) { "/customers/#{id}"}

  include_context 'shared base resource setup'

  describe '#find' do
    context 'success' do
      it 'returns expected result' do
        expect(client).to receive(:get).with(expected_path)

        expect(subject.find(id)).to eq(response_mash)
      end
    end

    context 'faillure' do
      let(:response_success?) { false }

      it 'raises error' do
        expect(client).to receive(:get).with(expected_path)

        expect{ subject.find(id) }.to raise_error("Error while finding #{expected_path} - #{error_messages}")
      end
    end
  end
end

shared_examples_for 'base resource create' do
  # TO BE SET BY SPEC
  # let(:id) { nil }
  # let(:expected_path) { '/customers' }
  include_context 'shared base resource setup'

  describe '#create' do
    let(:model_valid?) { true }
    let(:model_errors) { { errorKey1: 'message1', errorKey2: 'message2' } }
    let(:model_params) { double 'model_params' }
    let(:model) { double 'DwollaModel', to_params: model_params, valid?: model_valid?, errors: model_errors }

    context 'success' do
      it 'retrieves resource_location and id info' do
        expect(client).to receive(:post).with(expected_path, model_params)

        expect(subject.create(model, id)).to eq(true)
        expect(subject.id).to eq(resource_id)
        expect(subject.resource_location).to eq(resource_location)
      end
    end

    context 'failure - model validation' do
      let(:model_valid?) { false }

      it 'returns false and has errors' do
        expect(client).to_not receive(:post)

        expect(subject.create(model, id)).to eq(false)
        expect(subject.errors[:errorKey1]).to eq(['message1'])
        expect(subject.errors[:errorKey2]).to eq(['message2'])
      end
    end

    context 'failure - client call' do
      let(:response_success?) { false }
      let(:response_errors) do
        { responseErr1: 'err message1', responseErr2: 'err message2' }
      end

      it 'returns false and has errors' do
        expect(client).to receive(:post).with(expected_path, model_params)

        expect(subject.create(model, id)).to eq(false)
        expect(subject.errors[:responseErr1]).to eq(['err message1'])
        expect(subject.errors[:responseErr2]).to eq(['err message2'])
      end
    end
  end
end

shared_examples_for 'base resource update' do
  # TO BE SET BY SPEC
  #let(:id) { 777 }
  #let(:expected_config_path) { '/customers/:id' }
  #let(:expected_path) { "/customers/#{id}"}

  include_context 'shared base resource setup'

  describe '#update' do
    let(:model_valid?) { true }
    let(:model_errors) { { errorKey1: 'message1', errorKey2: 'message2' } }
    let(:model_params) { double 'model_params' }
    let(:model) { double 'DwollaModel', to_params: model_params, valid?: model_valid?, errors: model_errors }

    context 'success' do
      it 'returns true' do
        expect(model).to receive(:valid?)
        expect(client).to receive(:post).with(expected_path, model_params)

        expect(subject.update(model, id)).to eq(true)
      end
    end

    context 'failure - id param not provided' do
      it 'raises error' do
        expect(model).to_not receive(:valid?)
        expect(client).to_not receive(:post)

        expect{ subject.update(model) }.to raise_error("Expected additional url id parameters #{expected_config_path} - ids:[]")
      end
    end

    context 'failure - model validation' do
      let(:model_valid?) { false }

      it 'returns false and has errors' do
        expect(client).to_not receive(:post)

        expect(subject.update(model, id)).to eq(false)
        expect(subject.errors[:errorKey1]).to eq(['message1'])
        expect(subject.errors[:errorKey2]).to eq(['message2'])
      end
    end

    context 'failure - client call' do
      let(:response_success?) { false }
      let(:response_errors) do
        { responseErr1: 'err message1', responseErr2: 'err message2' }
      end

      it 'returns false and has errors' do
        expect(client).to receive(:post).with(expected_path, model_params)

        expect(subject.update(model, id)).to eq(false)
        expect(subject.errors[:responseErr1]).to eq(['err message1'])
        expect(subject.errors[:responseErr2]).to eq(['err message2'])
      end
    end
  end
end

shared_examples_for 'base resource destroy' do
  # TO BE SET IN SPEC
  #let(:id) { 777 }
  #let(:expected_config_path) { '/customers/:id' }
  #let(:expected_path) { "/customers/#{id}"}
  #
  include_context 'shared base resource setup'

  describe '#destroy' do
    context 'success' do
      it 'returns true' do
        expect(client).to receive(:delete).with(expected_path)

        expect(subject.destroy(id)).to eq(true)
      end
    end

    context 'failure - id param not provided' do
      it 'raises error' do
        expect(client).to_not receive(:delete)

        expect{ subject.destroy }.to raise_error("Expected additional url id parameters #{expected_config_path} - ids:[]")
      end
    end

    context 'failure - client call' do
      let(:response_success?) { false }
      let(:response_errors) do
        { responseErr1: 'err message1', responseErr2: 'err message2' }
      end

      it 'returns false and has errors' do
        expect(client).to receive(:delete).with(expected_path)

        expect(subject.destroy(id)).to eq(false)
        expect(subject.errors[:responseErr1]).to eq(['err message1'])
        expect(subject.errors[:responseErr2]).to eq(['err message2'])
      end
    end
  end
end
