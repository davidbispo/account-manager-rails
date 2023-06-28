require_relative 'event_processor_strategy'

module Strategies
  module Events
    class WithdrawStrategy < Strategies::Events::EventProcessorStrategy
      attr_accessor :account_id, :amount, :result

      def self.should_run_for?(event)
        event == 'withdraw'
      end

      def initialize(args)
        @account_id = args["origin"]
        @amount = args["amount"]
      end

      def execute
        @result = Services::Accounts::WithdrawFromAccountService.new(
          account_id: account_id,
          amount: amount
        ).perform
        self
      end

      def response
        if result['status'] == 'failed'
          res = { status: result['response_status'], message: '0' }
        else
          res = {
            status: @result['response_status'],
            message: {
              origin:
                {
                  id: account_id.to_s,
                  balance: Account.find(account_id).balance
                }
            }
          }
        end
        Hashie::Mash.new(res)
      end
    end
  end
end