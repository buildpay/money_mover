require 'spec_helper'

describe MoneyMover::Dwolla::CustomerTransferResource do
  let(:customer_id) { 123987 }
  let(:funding_source_id) { 777 }

  it_behaves_like 'base resource find' do
    let(:id) { funding_source_id }
    let(:expected_path) { "/transfers/#{id}" }
  end

  it_behaves_like 'base resource create' do
    let(:id) { customer_id }
    let(:expected_path) { "/transfers" }
  end

  describe '#cancel_transfer' do
    include_context 'shared base resource setup'

    let(:id) { 888 }
    let(:expected_path) { "/transfers/#{id}" }
    let(:expected_params) { { status: 'cancelled' } }

    context 'success' do
      it 'returns true' do
        expect(client).to receive(:post).with(expected_path, expected_params)
        expect(subject.cancel_transfer(id))
      end
    end

    context 'failure - client call' do
      let(:response_success?) { false }
      let(:response_errors) do
        { responseErr1: 'err message1', responseErr2: 'err message2' }
      end

      it 'returns false and has errors' do
        expect(client).to receive(:post).with(expected_path, expected_params)

        expect(subject.cancel_transfer(id)).to eq(false)
        expect(subject.errors[:responseErr1]).to eq(['err message1'])
        expect(subject.errors[:responseErr2]).to eq(['err message2'])
      end
    end
  end

  describe '#get_failure_reason' do
    include_context 'shared base resource setup'

    let(:id) { 888 }
    let(:expected_path) { "/transfers/#{id}/failure" }

    context 'success' do
      it 'returns true' do
        expect(client).to receive(:get).with(expected_path)

        expect(subject.get_failure_reason(id)).to eq(response_mash)
      end
    end

    context 'failure' do
      let(:response_success?) { false }

      it 'raises error' do
        expect(client).to receive(:get).with(expected_path)

        expect{ subject.get_failure_reason(id) }.to raise_error("Error finding #{expected_path} - #{error_messages}")
      end
    end
  end
end
