require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe '#create_and_deposit' do
    before do
      get :create, params: body
    end

    context "information is correct" do
      context "and account does not exist" do
        let(:body) { { type: "deposit", destination: 100, amount: 10 } }

        it { expect(response).to have_http_status(:created) }

        it "expects body to match template" do
          expect(JSON.parse(response.body)).to match(expected_echo_create)
        end

      end
      context "and account exists" do
        let!(:account) { create(:account, balance:10) }

        let(:body) { { type: "deposit", destination: account.id, amount: 10 } }

        it { expect(response).to have_http_status(:created)  }

        it "expects body to match template" do
          expect(JSON.parse(response.body)).to match(expected_echo_deposit(account.id))
        end
      end
    end

    context "information is incorrect" do
      let (:body) { { type: "potato", color: "yellow", size: 10 } }
      it { expect(response).to have_http_status(:not_acceptable) }
    end
  end

  def expected_echo_create
    { "destination" =>
        { "id" => "100",
          "balance" => 10 }
    }
  end

  def expected_echo_deposit(account_id)
    {
      "destination" =>
        { "id" => account_id.to_s,
          "balance" => 20
        }
    }
  end
end