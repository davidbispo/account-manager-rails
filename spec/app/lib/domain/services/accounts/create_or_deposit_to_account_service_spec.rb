require 'rails_helper'

RSpec.describe Services::Accounts::CreateOrDepositToAccountService do
  describe '#perform' do
    let(:perform) { described_class.new(**args).perform }

    context 'and params are correct' do
      let!(:args) { {
        account_id: account_id,
        balance: Faker::Number.number(digits: 2)
      } }

      context 'and account exists' do
        let(:account_id) { create(:account).id }
        it 'expects a return with a conflict message' do
          result = perform
          expect(result['message']).to eq('account already exists')
        end
      end

      context 'and account DOES NOT exist' do
        let(:account_id) { Faker::Number.number(digits: 9) }
        before do
          Account.all.destroy_all
          @result = perform
        end

        it 'creates the account correctly' do
          record = Account.find_by(id: args[:account_id])
          expect(record).not_to be_nil
          expect(record.balance).to eq(args[:balance])
        end

        it 'expects a confirmation echo be returned' do
          expect(@result['message']).to eq('account successfully created')
        end
      end
    end

    context 'and params are NOT correct' do
      let!(:args) { {
        account_id: Faker::Name.first_name,
        balance: true
      } }

      it 'expects a return with a validation message' do
        expect(@result['message']).to eq('Incorrect parameter set')
      end
    end
  end
end