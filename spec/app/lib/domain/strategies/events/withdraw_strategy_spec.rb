require 'rails_helper'

RSpec.describe Strategies::Events::WithdrawStrategy do
  describe ".ancestors" do
    it 'extends from EventProcessorStrategy' do
      expect(described_class.ancestors).to include(Strategies::Events::EventProcessorStrategy)
    end
  end

  describe '#execute' do
    let(:account_id) { '-50' }
    let(:amount) { 5 }
    let(:params) { { "origin" => account_id, "amount": amount }.with_indifferent_access }

    it 'expects the withdrawal service to be called' do
      mock_object = instance_double(Accounts::Services::WithdrawFromAccountService)
      allow(Accounts::Services::WithdrawFromAccountService).to receive(:new).and_return(mock_object)
      allow(mock_object).to receive(:perform)

      expect(mock_object)
        .to receive(:perform)
        .with({ account_id:account_id, amount:amount })
      described_class.new(params).execute
    end
  end
end