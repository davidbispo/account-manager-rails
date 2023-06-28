require 'rails_helper'

RSpec.describe Services::Events::ResolveEventService do
  describe "#resolve" do
    let(:perform) { described_class.new(event_type: event_type, request_params: params).resolve }

    context 'and strategy exists' do
      let(:service_class) { Services::Accounts::WithdrawFromAccountService }
      let(:strategy_class) { Strategies::Events::WithdrawStrategy }
      let(:event_type) { 'withdraw' }
      let(:params) { { "origin" => "-50", "amount" => 5 }.with_indifferent_access }

      context 'and strategy is successfully solved' do
        let(:expected_status) { {'status' => 'success', 'response_status' => 201} }

        before do
          mock_object = instance_double(service_class)
          allow(service_class).to receive(:new).and_return(mock_object)
          allow(mock_object).to receive(:perform).and_return(expected_status)

          account_mock = instance_double(Account, balance:Faker::Number.number(digits: 2))
          allow(Account).to receive(:find).and_return(account_mock)
        end

        it 'expects service to invoke strategy and collect response' do
          result_obj = perform
          expect(result_obj.status).to eq(201)
        end
      end

      context 'and strategy fails to set data and solve' do
        let(:expected_status) { {'status' => 'failed', 'response_status' => 422} }

        before do
          mock_object = instance_double(service_class)
          allow(service_class).to receive(:new).and_return(mock_object)
          allow(mock_object).to receive(:perform).and_return(expected_status)

          account_mock = instance_double(Account, balance:Faker::Number.number(digits: 2))
          allow(Account).to receive(:find).and_return(account_mock)
          allow(Account).to receive(:find_by).and_return(account_mock)
        end

        it 'expects service to invoke strategy and collect response' do
          result_obj = perform
          expect(result_obj.status).to eq(422)
        end
      end
    end

    context 'and strategy DOES NOT exist' do
      let(:event_type) { 'random_strategy' }
      let(:params) { { "param1" => "10", "param2" => 5 }.with_indifferent_access }

      it 'expects an error to be raised' do
        expect { perform }.to raise_error(ArgumentError, 'Invalid event type for Event Processor Strategy Resolution')
      end
    end
  end
end