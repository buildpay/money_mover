require 'spec_helper'

describe 'initate funding source micro-deposits' do
  let(:funding_source_token) { '9481924a-6795-4e7a-b436-a7a48a4141ca' }

  subject { MoneyMover::Dwolla::MicroDepositResource.new }

  let(:initiate_params) {{}}

  before do
    dwolla_helper.stub_funding_source_microdeposits_request funding_source_token, initiate_params, create_response
  end

  describe '#initiate' do
    context 'success' do
      let(:create_response) {{
        status: 201,
        body: ""
      }}

      it 'creates new resource in dwolla' do
        expect(subject.initiate(funding_source_token)).to eq(true)
      end
    end

    context 'fail' do
      let(:create_response) {{
        status: 400,
        body: error_response.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
      }}

      let(:error_response) {{
        code: "ValidationError",
        message: "Some error"
      }}

      it 'returns errors' do
        expect(subject.initiate(funding_source_token)).to eq(false)
        expect(subject.errors[:base]).to eq(['Some error'])
      end
    end
  end
end
