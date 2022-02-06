require 'rails_helper'

RSpec.describe Services::Accounts::GetBalanceForAccountService do
  describe '#perform' do
    let(:perform) { described_class.new(**args).perform }

    context 'and params are correct' do
      let(:args) { {
        account_id: account_id,
      } }

      context 'and account DOES NOT exist' do
        let!(:account_id) { Faker::Number.number(digits: 9) }
        before do
          Account.all.destroy_all
          @result = perform
        end

        it 'expects a return with a not found message' do
          result = perform
          expect(result['message']).to eq('Account not found')
        end
      end

      context 'and account DOES exist' do
        let!(:account) { create(:account) }
        let!(:account_id) { account.id }

        before do
          @old_balance = account.balance
          @result = perform
        end

        after do
          Account.all.destroy_all
        end

        context 'and balance retrieval is succcessful' do
          it 'expects no error message' do
            expect(@result['message']).to be(nil)
          end

          it 'the balance value to match the value on the db' do
            record = Account.find_by(id: args[:account_id])
            expect(record).not_to be_nil
            expect(@result['balance']).to eq(record.balance)
          end
        end
      end
    end
    context 'and params are NOT correct' do
      let!(:args) { {
        account_id: [],
      } }

      it 'expects a return with a validation message' do
        result = perform
        expect(result['message']).to eq('Incorrect parameter set')
      end
    end
  end
end