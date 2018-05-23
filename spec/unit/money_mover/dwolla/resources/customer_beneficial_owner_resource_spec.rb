require 'spec_helper'

describe MoneyMover::Dwolla::CustomerBeneficialOwnerResource do
  let(:customer_id) { 123987 }
  let(:beneficial_owner_id) { 12 }

  it_behaves_like 'base resource list' do
    let(:id) { customer_id }
    let(:expected_path) { "/customers/#{id}/beneficial-owners" }
    let(:valid_filter_params) { [] }
  end

  it_behaves_like 'base resource find' do
    let(:id) { beneficial_owner_id }
    let(:expected_path) { "/beneficial-owners/#{id}" }
  end

  it_behaves_like 'base resource create' do
    let(:id) { customer_id }
    let(:expected_path) { "/customers/#{id}/beneficial-owners" }
  end

  it_behaves_like 'base resource update' do
    let(:id) { beneficial_owner_id }
    let(:expected_config_path) { '/beneficial-owners/:id' }
    let(:expected_path) { "/beneficial-owners/#{id}" }
  end

  it_behaves_like 'base resource destroy' do
    let(:id) { beneficial_owner_id }
    let(:expected_config_path) { '/beneficial-owners/:id' }
    let(:expected_path) { "/beneficial-owners/#{id}" }
  end
end
