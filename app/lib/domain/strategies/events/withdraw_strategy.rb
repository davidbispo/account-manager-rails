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
        @result = Accounts::Services::WithdrawFromAccountService.new.perform(
          account_id: account_id,
          amount: amount
        )
        self
      end

      def response
        if result
          res = { status: 200, result: result }
        else
          res = { status: 500, result: 'error' }
        end
        Hashie::Mash.new(res)
      end
    end
  end
end