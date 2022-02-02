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

      let(:destination_account) { create(:account) }
      let(:destination_account_id) { destination_account.id }

      context 'and any of the accounts DO NOT exist' do
        let(:origin_account_id) { Faker::Number.number(digits: 9) }

        before do
          @old_balance = destination_account.balance
          Account.all.destroy_all
          @result = perform
        end

        it 'expects balance on origin account to be untouched' do
          record = Account.find_by(id: args[:account_id])
          expect(record).not_to be_nil
          expect(record.balance).to eq(@old_balance)
        end

        it 'expects a an error message be returned' do
          expect(@result['message']).to eq('Invalid accounts parameter set')
        end
      end
      context 'and all accounts exist' do
        let(:origin_account) { create(:account) }
        let(:origin_account_id) { origin_account.id }

        context 'and transfer is successful' do
          before do
            Account.all.destroy_all
            @old_balance_origin = origin_account.balance
            @old_balance_destination = destination_account.balance
            @result = perform
          end

          it 'expects a confirmation message' do
            expect(@result['message']).to be('transfer successful')
          end

          it 'expect balance on origin account to be updated on db' do
            origin_account_record = Account.find_by(id: args[:origin_account_id])
            expect(origin_account_record).not_to be_nil
            expect(origin_account_record.balance).to eq(@old_balance_origin - args[:amount])
          end

          it 'expects balance on destination account to be updated on db' do
            origin_account_record = Account.find_by(id: args[:origin_account_id])
            expect(origin_account_record).not_to be_nil
            expect(origin_account_record.balance).to eq(@old_balance_origin + args[:amount])
          end
        end

        context 'and transfer fails' do
          it 'expect balance on origin account to remain untouched' do
            origin_account_record = Account.find_by(id: args[:origin_account_id])
            expect(origin_account_record).not_to be_nil
            expect(origin_account_record.balance).to eq(@old_balance_origin)
          end

          it 'expects balance on destination account to remain untouched' do
            origin_account_record = Account.find_by(id: args[:origin_account_id])
            expect(origin_account_record).not_to be_nil
            expect(origin_account_record.balance).to eq(@old_balance_origin)
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

      it 'expects a return with a validation message' do
        expect(@result['message']).to eq('Incorrect parameter set')
      end
    end
  end
end