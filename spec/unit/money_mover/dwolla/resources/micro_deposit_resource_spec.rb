require 'spec_helper'

describe MoneyMover::Dwolla::MicroDepositResource do
  let(:funding_source_id) { 777 }

  describe '#initiate' do
    include_context 'shared base resource setup'

    let(:expected_path) { "/funding-sources/#{funding_source_id}/micro-deposits" }

    context 'success' do
      it 'initiates microdeposts' do
        expect(client).to receive(:post).with(expected_path, {})

        expect(subject.initiate(funding_source_id)).to eq(true)
      end
    end

    context 'failure - client call' do
      let(:response_success?) { false }
      let(:response_errors) do
        { responseErr1: 'err message1', responseErr2: 'err message2' }
      end

      it 'has errors' do
        expect(client).to receive(:post).with(expected_path, {})

        expect(subject.initiate(funding_source_id)).to eq(false)
        expect(subject.errors[:responseErr1]).to eq(['err message1'])
        expect(subject.errors[:responseErr2]).to eq(['err message2'])
      end
    end
  end

  it_behaves_like 'base resource update' do
    let(:id) { funding_source_id }
    let(:expected_config_path) { '/funding-sources/:funding_source_id/micro-deposits' }
    let(:expected_path) { "/funding-sources/#{id}/micro-deposits" }
  end

  it_behaves_like 'base resource find' do
    let(:id) { funding_source_id }
    let(:expected_path) { "/funding-sources/#{id}/micro-deposits" }
  end
end
