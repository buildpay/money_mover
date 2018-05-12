require 'spec_helper'

describe MoneyMover::Dwolla::WebhookSubscriptionResource do
  let(:subscription_id) { 1234 }

  it_behaves_like 'base resource list' do
    let(:id) { nil }
    let(:expected_path) { '/webhook-subscriptions' }
    let(:valid_filter_params) { [] }
  end

  it_behaves_like 'base resource find' do
    let(:id) { subscription_id }
    let(:expected_path) { "/webhook-subscriptions/#{id}" }
  end

  it_behaves_like 'base resource create' do
    let(:id) { nil }
    let(:expected_path) { '/webhook-subscriptions' }
  end

  it_behaves_like 'base resource update' do
    let(:id) { 777 }
    let(:expected_config_path) { '/webhook-subscriptions/:id' }
    let(:expected_path) { "/webhook-subscriptions/#{id}" }
  end

  it_behaves_like 'base resource destroy' do
    let(:id) { 999 }
    let(:expected_config_path) { '/webhook-subscriptions/:id' }
    let(:expected_path) { "/webhook-subscriptions/#{id}" }
  end
end
