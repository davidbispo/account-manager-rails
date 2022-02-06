require 'rails_helper'

RSpec.describe Services::Accounts::CreateOrDepositToAccountService do
  describe '#perform' do
    let(:perform) { described_class.new(**args).perform }
    let(:mocked_class_deposit) { Services::Accounts::DepositToAccountService }
    let(:mocked_class_create) { Services::Accounts::CreateAccountService }


    context 'and params are correct' do
      let!(:args) { {
        account_id: account_id,
        amount: Faker::Number.number(digits: 2)
      } }

      context 'and account exists' do
        let(:account_id) {
          Account.all.destroy_all
          create(:account).id
        }

        it 'expects the deposit to account service to be called' do
          mock_object_deposit = instance_double(mocked_class_deposit)
          allow(mocked_class_deposit).to receive(:new).and_return(mock_object_deposit)
          allow(mock_object_deposit).to receive(:perform)
          expect(mocked_class_deposit).to receive(:new).with({account_id: account_id, amount: args[:amount]})
          expect(mock_object_deposit).to receive(:perform)
          perform
        end
      end

      context 'and account DOES NOT exist' do
        let(:account_id) { Faker::Number.number(digits: 9) }
        before{ Account.all.destroy_all }

        it 'expects the create account service to be called' do
          mock_object_create = instance_double(mocked_class_create)
          allow(mocked_class_create).to receive(:new).and_return(mock_object_create)
          allow(mock_object_create).to receive(:perform)
          expect(mocked_class_create).to receive(:new).with({account_id: account_id, balance: args[:amount]})
          expect(mock_object_create).to receive(:perform)
          perform
        end
      end
    end

    context 'and params are NOT correct' do
      let!(:args) { {
        account_id: Faker::Name.first_name,
        amount: true
      } }

      it 'expects a return with a validation message' do
        result = perform
        expect(result['message']).to eq('Incorrect parameter set')
      end
    end
  end
end