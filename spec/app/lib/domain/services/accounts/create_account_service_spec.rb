require 'rails_helper'

RSpec.describe Services::Accounts::CreateAccountService do
  let(:perform) { described_class.new(**args).perform }
  describe '#perform' do
    context 'and params are correct' do
      context 'and account exists'
      let(:account) { create(:account) }

      let!(:args) { {
        account_id: account.id,
        balance: Faker::Number.number(digits: 2)
      } }

      after do
        Account.all.destroy_all
      end

      it 'expects a return with a conflict message' do
        result = perform
        expect(result['message']).to eq('account already exists')
      end
    end

    context 'and account DOES NOT exist' do
      let(:args) { {
        account_id: Faker::Number.number(digits: 10),
        balance: Faker::Number.number(digits: 2)
      } }

      before do
        Account.all.destroy_all
        @result = perform
      end

      it 'expects account to be on db and balance valid' do
        record = Account.find_by(id:args[:account_id])
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

    before do
      @result = perform
    end

    it 'expects a return with a validation message' do
      expect(@result['message']).to eq('Incorrect parameter set')
    end
  end
end
