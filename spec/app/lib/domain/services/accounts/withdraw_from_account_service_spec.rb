require 'rails_helper'

RSpec.describe Services::Accounts::WithdrawFromAccountService do
  describe '#perform' do
    let(:perform) { described_class.new(**args).perform }
    context 'and params are correct' do
      let(:args) { {
        account_id: account_id,
        amount: Faker::Number.number(digits: 2)
      } }

      context 'and account DOES NOT exist' do
        let!(:account_id) { Faker::Number.number(digits: 10) }

        before do
          Account.all.destroy_all
          @result = perform
        end

        it 'expects a return with a not found message' do
          expect(@result['message']).to eq('account not found')
        end
      end
      context 'and account exists' do
        let!(:account) { create(:account) }
        let!(:account_id) { account.id }

        before do
          Account.all.destroy_all
          @old_balance = account.balance
          @result = perform
        end

        context 'and withdrawal succeeds' do
          it 'expects balance on account to be update on db' do
            record = Account.find_by(id: args[:account_id])
            expect(record).not_to be_nil
            expect(record.balance).to eq(@old_balance - args[:amount])
          end

          it 'expects a confirmation message' do
            expect(@result['message']).to be('withdrawal successful')
          end
        end

        context 'and withdrawal fails' do
          it 'expects balance on account to be untouched' do
            record = Account.find_by(id: args[:account_id])
            expect(record).not_to be_nil
            expect(record.balance).to eq(@old_balance)
          end
        end
      end
    end

    context 'and params are NOT correct' do
      let!(:args) { {
        account_id: Faker::Name.first_name,
        amount: true
      } }

      it 'expects a return with a validation message' do
        expect(@result['message']).to eq('Incorrect parameter set')
      end
    end
  end
end