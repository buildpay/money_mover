require 'spec_helper'

describe MoneyMover::Dwolla::CustomerDocumentResource do
  let(:customer_id) { 123987 }
  let(:document_id) { 777 }

  it_behaves_like 'base resource list' do
    let(:id) { customer_id }
    let(:expected_path) { "/customers/#{id}/documents" }
    let(:valid_filter_params) { [] }
  end

  it_behaves_like 'base resource find' do
    let(:id) { document_id }
    let(:expected_path) { "/documents/#{id}" }
  end

  it_behaves_like 'base resource create' do
    let(:id) { customer_id }
    let(:expected_path) { "/customers/#{id}/documents" }
  end
end
