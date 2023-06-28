require 'rails_helper'

RSpec.describe Strategies::Events::DepositStrategy do
  describe ".ancestors" do
    it 'extends from EventProcessorStrategy' do
      expect(described_class.ancestors).to include(Strategies::Events::EventProcessorStrategy)
    end
  end

  describe '#execute' do
    let(:account_id) { 10 }
    let(:amount) { 5 }

    let(:params) { {
      "destination" => account_id,
      "amount" => amount,
    }.with_indifferent_access }

    let(:mocked_class_create) { Services::Accounts::CreateAccountService }
    let(:mocked_class_deposit) { Services::Accounts::DepositToAccountService }

    context 'and account does not exit' do
      let(:account_id) { Faker::Number.number(digits: 10) }
      let(:expected_status) { {'status' => 'success', 'response_status' => 201} }

      before do
        mock_object = instance_double(mocked_class_create)
        allow(mocked_class_create).to receive(:new).and_return(mock_object)
        allow(mock_object).to receive(:perform).and_return(expected_status)

        @account_mock = instance_double(Account)
        allow(Account).to receive(:find).and_return(nil)
        allow(Account).to receive(:find_by).and_return(nil)
      end

      it 'expects the create service to have been called' do
        expect(mocked_class_create).to receive(:new).with(
          {
            account_id: account_id,
            balance: amount,
          })
        params
        described_class.new(**params).execute
      end
    end

    context 'and account exists' do
      before do
        mock_object = instance_double(Account)
        allow(Account).to receive(:find).and_return(mock_object)
        allow(Account).to receive(:find_by).and_return(mock_object)

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
        described_class.new(**params).execute
      end
    end
  end
end