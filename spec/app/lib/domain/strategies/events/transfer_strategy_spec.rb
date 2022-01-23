require 'rails_helper'

RSpec.describe Strategies::Events::TransferStrategy do
  describe ".ancestors" do
    it 'extends from EventProcessorStrategy' do
      expect(described_class.ancestors).to include(Strategies::Events::EventProcessorStrategy)
    end
  end

  describe '#execute' do
    let(:origin_account_id) { '10' }
    let(:destination_account_id) { '15' }
    let(:amount) { 5 }

    let(:params) { {
      "origin_account_id" => origin_account_id,
      "amount" => amount,
      "destination_account_id" => destination_account_id
    }.with_indifferent_access }

    let(:mocked_class) { Accounts::Services::TransferBetweenAccountsService }

    it 'expects the transfer service to be called' do
      mock_object = instance_double(mocked_class)
      allow(mocked_class).to receive(:new).and_return(mock_object)
      allow(mock_object).to receive(:perform)

      expect(mocked_class).to receive(:new).with(
        {
          origin_account_id: origin_account_id,
          destination_account_id: destination_account_id,
          amount:amount
        })
      described_class.new(params).execute
    end
  end
end