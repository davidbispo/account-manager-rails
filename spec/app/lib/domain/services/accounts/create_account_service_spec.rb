require 'rails_helper'

RSpec.describe Services::Accounts::CreateAccountService do
  let(:perform) { described_class.new(**args).perform }
  describe '#perform' do
    context 'and params are correct' do
      context 'and account exists'
      let!(:account) do
        Account.all.destroy_all
        create(:account)
      end

      let!(:args) do
        { account_id: account.id,
          balance: Faker::Number.number(digits: 2) }
      end

      after { Account.all.destroy_all }

      it 'expects a return 409 with a conflict message' do
        result = perform
        expect(result['message']).to eq('Account already exists')
        expect(result['response_status']).to eq(409)
        expect(result['status']).to eq('failed')
      end
    end

    context 'and account DOES NOT exist' do
      let(:args) { {
        account_id: Faker::Number.number(digits: 10),
        balance: Faker::Number.number(digits: 2)
      } }

      context 'and account creation is successful' do
        before do
          Account.all.destroy_all
          @result = perform
        end

        it 'expects account to be on db and balance valid' do
          record = Account.find_by(id: args[:account_id])
          expect(record).not_to be_nil
          expect(record.balance).to eq(args[:balance])
        end

        it 'expects a success message to be returned' do
          expect(@result['message']).to eq('Account creation successful')
        end

        it 'expects response_status returned to be 201' do
          expect(@result['response_status']).to eq(201)
        end

        it 'expects return status to be success' do
          expect(@result['status']).to eq('success')
        end
      end

      context 'and account creation fails' do
        before do
          Account.all.destroy_all
          allow(Account).to receive(:create!).and_raise(ActiveRecord::Rollback)
          @result = perform
        end

        it 'expects a success message to be returned' do
          expect(@result['message']).to eq('Account creation failed')
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
      balance: true
    } }

    before do
      @result = perform
    end

    it 'expects return with a validation message' do
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
