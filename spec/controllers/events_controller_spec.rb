require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe '#create_and_deposit' do
    before do
      get :create, params: body
    end

    context "information is incorrect" do
      let (:body) { { type: "potato", color: "yellow", size: 10 } }
      it { expect(response).to have_http_status(:not_acceptable) }
    end

    context "information is correct" do
      context "and accounts does not exist" do
        let(:body) { { type: "deposit", destination: 100, amount: 10 } }

        it { expect(response).to have_http_status(:created) }

        it "expects body to match template" do
          expect(JSON.parse(response.body)).to match(successful_create_response)
        end

      end
      context "and accounts exists" do
        let!(:account) { create(:account, balance: 10) }

        let(:body) { { type: "deposit", destination: account.id, amount: 10 } }

        it { expect(response).to have_http_status(:created) }

        it "expects body to match template" do
          expect(JSON.parse(response.body)).to match(successful_deposit_response(account.id))
        end
      end
    end
  end

  context 'transfer between accounts' do
    context "and accounts exists" do
      before do
        let!(:origin_account) { create(:account, balance: 15) }
        let!(:destination_account) { create(:account, balance: 10) }

        payload = {
          "type" => "transfer",
          "origin" => origin_account.id.to_s,
          "amount": 15,
          "destination" => destination_account.id.to_s
        }
        post("/event", params: payload)
      end

      it "expects a correct response from the API" do
        it { expect(response).to have_http_status(:created) }
      end

      it "expects body to match template" do
        expect(JSON.parse(response.body)).to match(expected_echo_transfer_success(origin_account.id, destination_account.id))
      end
    end

    context "and origin accounts does not exist" do
      let (:payload) { { "type" => "transfer", "origin" => "9999", "amount": 15, "destination" => "303" } }
      before do
        post("/event", params: payload)
      end

      it "expects body to match template" do
        expect(response.body).eq eq('0')
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    def expected_echo_transfer_success(origin_account_id, destination_account_id)
      {
        "origin" => {
          "id" => origin_account_id.to_s,
          "balance" => 0
        },
        "destination" =>
          { "id" => destination_account_id.to_s,
            "balance" => 15
          }
      }
    end
  end

  context 'withdrawal from accounts' do
    before do
      let!(:account) { create(:account, balance: 20) }
      let(:payload) { { "type" => "withdraw", "origin" => account.id, "amount": 5 } }
      post("/event", params: payload)
    end

    context "and accounts exists" do
      it "expects a correct response from the API" do
        it { expect(response).to have_http_status(:created) }
      end

      it "expects body to match template" do
        expect(JSON.parse(response.body)).to match(response_template)
      end
    end

    context "and accounts does not exist" do
      let (:payload) { { "type" => "withdraw", "origin" => "-50", "amount": 5 } }
      before do
        post("/event", params: payload)
      end
      it { expect(response).to have_http_status(:created) }
      it { expect(response.body).eq eq('0') }
    end

    def successful_withdrawal_response(account_id)
      {
        "origin" =>
          {
            "id" => account_id.to_s,
            "balance" => 15
          }
      }
    end
  end

  def successful_create_response
    { "destination" =>
        { "id" => "100",
          "balance" => 10 }
    }
  end

  def successful_deposit_response(account_id)
    {
      "destination" =>
        { "id" => account_id.to_s,
          "balance" => 20
        }
    }
  end
end