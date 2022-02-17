require 'rails_helper'

RSpec.describe Services::Accounts::TransferBetweenAccountsService do
  describe '#perform' do
    let(:perform) { described_class.new(**args).perform }
    context 'and params are correct' do
      let(:args) { {
        origin_account_id: origin_account_id,
        destination_account_id: destination_account_id,
        amount: Faker::Number.number(digits: 2)
      } }

      context 'and any of the accounts DO NOT exist' do
        let(:origin_account_id) { Faker::Number.number(digits: 9) }

        let!(:destination_account) {
          Account.all.destroy_all
          create(:account)
        }
        let!(:destination_account_id) { destination_account.id }

        before do
          @old_balance = destination_account.balance
          @result = perform
        end

        after { Account.all.destroy_all }

        it 'expects balance on origin account to be untouched' do
          record = Account.find_by(id: destination_account_id)
          expect(record).not_to be_nil
          expect(record.balance).to eq(@old_balance)
        end

        it 'expects a return with an error message' do
          expect(@result['message']).to eq('Invalid accounts parameter set')
        end

        it 'expects response_status returned to be 422' do
          expect(@result['response_status']).to eq(422)
        end

        it 'expects return status to be failed' do
          expect(@result['status']).to eq('failed')
        end
      end

      context 'and all accounts exist' do
        let(:accounts) {
          Account.all.destroy_all
          create_list(:account, 2)
        }

        after { Account.all.destroy_all }

        let(:origin_account) { accounts.first }
        let(:origin_account_id) { origin_account.id }

        let(:destination_account) { accounts.second }
        let(:destination_account_id) { destination_account.id }

        context 'and transfer is successful' do
          before do
            @old_balance_origin = origin_account.balance
            @old_balance_destination = destination_account.balance
            @result = perform
          end

          it 'expects a return with a success message' do
            expect(@result['message']).to eq('Transfer successful')
          end

          it 'expects response_status returned to be 200' do
            expect(@result['response_status']).to eq(200)
          end

          it 'expects return status to be success' do
            expect(@result['status']).to eq('success')
          end

          it 'expect balance on origin account to be updated on db' do
            origin_account_record = Account.find_by(id: args[:origin_account_id])
            expect(origin_account_record).not_to be_nil
            expect(origin_account_record.balance).to eq(@old_balance_origin - args[:amount])
          end

          it 'expects balance on destination account to be updated on db' do
            origin_account_record = Account.find_by(id: destination_account_id)
            expect(origin_account_record).not_to be_nil
            expect(origin_account_record.balance).to eq(@old_balance_destination + args[:amount])
          end
        end

        context 'and transfer fails' do
          let(:balance) { Faker::Number.number(digits: 2) }
          before do
            @account_double = instance_double(Account)
            allow(Account).to receive(:find_by).and_return(@account_double)
            allow(@account_double).to receive(:balance).and_return(balance)
            allow(@account_double).to receive(:update).and_raise(ActiveRecord::Rollback)
            @old_balance_origin = origin_account.balance
            @old_balance_destination = destination_account.balance
            @result = perform
          end

          it 'expects a return with an error message' do
            expect(@result['message']).to eq('Transfer failed')
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
        origin_account_id: Faker::Name.first_name,
        destination_account_id: [],
        amount: true
      } }

      before do
        @result = perform
      end

      it 'expects a return with a validation message' do
        expect(@result['message']).to eq('Incorrect parameter set')
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