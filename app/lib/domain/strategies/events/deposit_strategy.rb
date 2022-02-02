module Strategies
  module Events
    class DepositStrategy < Strategies::Events::EventProcessorStrategy
      attr_accessor :account_id, :amount, :result

      def self.should_run_for?(event)
        event == 'deposit'
      end

      def initialize(args)
        @account_id = args["account_id"]
        @amount = args["amount"]
        self
      end

      def execute
        account = ::Account.find(account_id)
        unless account
          Services::Accounts::CreateAccountService.new(account_id: account_id, balance: amount).perform
        end
        @result = Services::Accounts::DepositToAccountService.new(account_id: account_id, amount: amount).perform
        self
      end

      def response
        if result
          res = { status: 200, result: result.to_json }
        else
          res = { status: 500, result: 'error' }
        end
        Hashie::Mash.new(res)
      end
    end
  end
end