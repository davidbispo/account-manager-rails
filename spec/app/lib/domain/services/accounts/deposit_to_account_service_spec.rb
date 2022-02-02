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
          @result = perform
        end

        it 'expects a return with a not found message' do
          result = perform
          expect(result['message']).to eq('account not found')
        end
      end

      context 'and account DOES exist' do
        let!(:account) { create(:account) }
        let!(:account_id) { account.id }

        before do
          @old_balance = account.balance
          perform
        end

        context 'and deposit is succcessful' do
          it 'updates account balance on db' do
            record = Account.find_by(id: args[:account_id])
            expect(record).not_to be_nil
            expect(record.balance).to eq(@old_balance + args[:amount])
          end
        end

        context 'and deposit is fails' do
          it 'expects balance on account to remain untouched' do
            record = Account.find_by(id: args[:account_id])
            expect(record).not_to be_nil
            expect(record.balance).to eq(@old_balance)
          end
        end

        it 'expects a confirmation echo be returned' do
          expect(@result['message']).to eq('deposit successfully done')
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