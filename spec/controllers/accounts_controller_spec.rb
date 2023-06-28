require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:body) { { id: account_id } }

  before do
    get :get_balance, params: body
  end

  context 'and account exists' do
    let(:account) {
      Account.all.destroy_all
      create(:account)
    }
    let(:account_id) { account.id }

    after { Account.all.destroy_all }

    it { expect(response).to have_http_status(:ok) }

    it "expects body to match template" do
      expect(response.body).to eq(account.balance.to_s)
    end
  end

  context 'and account DOES NOT exist' do
    let(:account_id) { Faker::Number.number(digits: 9) }

    after { Account.all.destroy_all }

    it { expect(response).to have_http_status(:not_found) }

    it "expects body to match template" do
      expect(response.body).to eq('0')
    end
  end
end