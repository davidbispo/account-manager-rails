require 'rails_helper'

RSpec.describe Services::Accounts::DepositToAccountService do
  describe '#perform' do
    let(:perform) { described_class.new(**args).perform }

    context 'and params are correct' do
      let!(:args) { {
        account_id: account_id,
        amount: Faker::Number.number(digits: 2)
      } }

      context 'and account DOES NOT exist' do
        let(:account_id) { Faker::Number.number(digits: 9) }
        before do
          Account.all.destroy_all
        end

        it 'expects a return with a not found message' do
          result = perform
          expect(result['message']).to eq('Account not found')
        end
      end

      context 'and account DOES exist' do
        let!(:account) { create(:account) }
        let!(:account_id) { account.id }

        context 'and deposit is succcessful' do
          before do
            @old_balance = account.balance
            @result = perform
          end

          it 'updates account balance on db' do
            record = Account.find_by(id: args[:account_id])
            expect(record).not_to be_nil
            expect(record.balance).to eq(@old_balance + args[:amount])
          end

          it 'expects a confirmation echo be returned' do
            expect(@result['message']).to eq('Deposit successful')
          end
        end

        context 'and deposit is fails' do
          let(:balance) { account.balance }
          before do
            account_double = instance_double(Account)
            allow(Account).to receive(:find_by).and_return(account_double)
            allow(account_double).to receive(:balance).and_return(balance)
            allow(account_double).to receive(:update).and_raise(ActiveRecord::Rollback)
            @old_balance = account.balance
            @result = perform
          end

          it 'expects balance on account to remain untouched' do
            record = Account.find_by(id: args[:account_id])
            expect(record).not_to be_nil
            expect(record.balance).to eq(@old_balance)
          end

          it 'expects an error message be returned' do
            expect(@result['message']).to eq('Deposit failed')
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
        result = perform
        expect(result['message']).to eq('Incorrect parameter set')
      end
    end
  end
end