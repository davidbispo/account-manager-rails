require 'rails_helper'

RSpec.describe Strategies::Events::DepositStrategy do
  describe ".ancestors" do
    it 'extends from EventProcessorStrategy' do
      expect(described_class.ancestors).to include(Strategies::Events::EventProcessorStrategy)
    end
  end

  describe '#execute' do
    let(:account_id) { '10' }
    let(:amount) { 5 }

    let(:params) { {
      "account_id" => account_id,
      "amount" => amount,
    }.with_indifferent_access }

    let(:mocked_class_create) { Accounts::Services::CreateAccountService }
    let(:mocked_class_deposit) { Accounts::Services::DepositToAccountService }

    context 'and account does not exit' do
      before do
        mock_object = instance_double(mocked_class_create)
        allow(mocked_class_create).to receive(:new).and_return(mock_object)
        allow(mock_object).to receive(:perform)
        allow(Account).to receive(:find).and_return(nil)
      end

      it 'expects the deposit service to have been called' do
        expect(mocked_class_create).to receive(:new).with(
          {
            account_id: account_id,
            balance: amount,
          })
        described_class.new(params).execute
      end

    end

    context 'and account exists' do
      before do
        mock_object = instance_double(Account)
        allow(Account).to receive(:find).and_return(mock_object)

        mock_object = instance_double(mocked_class_deposit)
        allow(mocked_class_deposit).to receive(:new).and_return(mock_object)
        allow(mock_object).to receive(:perform)
      end

      it 'expects the deposit service to have been called' do
        expect(mocked_class_deposit).to receive(:new).with(
          {
            account_id:account_id,
            amount:amount,
          })
        described_class.new(params).execute
      end
    end
  end
end