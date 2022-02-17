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
          expect(@result['message']).to eq('Account not found')
        end

        it 'expects response_status returned to be 404' do
          expect(@result['response_status']).to eq(404)
        end

        it 'expects return status to be success' do
          expect(@result['status']).to eq('failed')
        end
      end
      context 'and account exists' do
        let!(:account) {
          Account.all.destroy_all
          create(:account)
        }
        let!(:account_id) { account.id }

        after { Account.all.destroy_all }

        context 'and withdrawal succeeds' do
          before do
            @old_balance = account.balance
            @result = perform
          end

          it 'expects balance on account to be update on db' do
            record = Account.find_by(id: account_id)
            expect(record).not_to be_nil
            expect(record.balance).to eq(@old_balance - args[:amount])
          end

          it 'expects a return with a success message' do
            expect(@result['message']).to eq('Withdrawal successful')
          end

          it 'expects response_status returned to be 200' do
            expect(@result['response_status']).to eq(200)
          end

          it 'expects return status to be success' do
            expect(@result['status']).to eq('success')
          end
        end

        context 'and withdrawal fails' do
          let(:balance) { Faker::Number.number(digits: 2) }
          before do
            account_double = instance_double(Account)
            allow(Account).to receive(:find_by).and_return(account_double)
            allow(account_double).to receive(:balance).and_raise(ActiveRecord::Rollback)
            @result = perform
          end

          it 'expects a return with an error message' do
            expect(@result['message']).to eq('Withdrawal failed')
          end

          it 'expects response_status returned to be 422' do
            expect(@result['response_status']).to eq(422)
          end

          it 'expects return status to be failed' do
            expect(@result['status']).to eq('failed')
          end
        end
      end
    end

    context 'and params are NOT correct' do
      let!(:args) { {
        account_id: Faker::Name.first_name,
        amount: true
      } }

      before do
        @result = perform
      end

      it 'expects a return with a validation message' do
        expect(@result['message']).to eq('Incorrect parameter set')
      end

      it 'expects return status to be failed' do
        expect(@result['status']).to eq('failed')
      end
    end
  end
end