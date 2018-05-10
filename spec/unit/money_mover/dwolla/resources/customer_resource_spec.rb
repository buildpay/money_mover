require 'spec_helper'

describe MoneyMover::Dwolla::CustomerResource do
  let(:customer_id) { 777 }
  it_behaves_like 'base resource list' do
    let(:id) { nil }
    let(:expected_path) { '/customers' }
    let(:valid_filter_params) { [:search, :status, :limit, :offset ] }
  end

  it_behaves_like 'base resource find' do
    let(:id) { customer_id }
    let(:expected_path) { "/customers/#{id}" }
  end

  it_behaves_like 'base resource create' do
    let(:id) { nil }
    let(:expected_path) { '/customers' }
  end

  it_behaves_like 'base resource update' do
    let(:id) { 123 }
    let(:expected_config_path) { '/customers/:id' }
    let(:expected_path) { "/customers/#{id}" }
  end

  it_behaves_like 'base resource destroy' do
    let(:id) { 999 }
    let(:expected_config_path) { '/customers/:id' }
    let(:expected_path) { "/customers/#{id}" }
  end
end
