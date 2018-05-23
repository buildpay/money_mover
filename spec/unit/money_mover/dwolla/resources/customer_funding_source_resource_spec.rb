require 'spec_helper'

describe MoneyMover::Dwolla::CustomerFundingSourceResource do
  let(:customer_id) { 123987 }
  let(:funding_source_id) { 777 }

  it_behaves_like 'base resource list' do
    let(:id) { customer_id }
    let(:expected_path) { "/customers/#{id}/funding-sources" }
    let(:valid_filter_params) { [:removed] }
  end

  it_behaves_like 'base resource find' do
    let(:id) { funding_source_id }
    let(:expected_path) { "/funding-sources/#{id}" }
  end

  it_behaves_like 'base resource create' do
    let(:id) { customer_id }
    let(:expected_path) { "/customers/#{id}/funding-sources" }
  end

  it_behaves_like 'base resource update' do
    let(:id) { funding_source_id }
    let(:expected_config_path) { '/funding-sources/:id' }
    let(:expected_path) { "/funding-sources/#{id}" }
  end

  it_behaves_like 'base resource destroy' do
    let(:id) { funding_source_id }
    let(:expected_config_path) { '/funding-sources/:id' }
    let(:expected_path) { "/funding-sources/#{id}" }
  end
end
