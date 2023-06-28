module Strategies
  module Events
    class DepositStrategy < Strategies::Events::EventProcessorStrategy
      attr_accessor :account_id, :amount, :result

      def self.should_run_for?(event)
        event == 'deposit'
      end

      def initialize(args)
        @account_id = args["destination"]
        @amount = args["amount"]
        self
      end

      def execute
        account = Account.find_by(id: account_id)
        if account.blank?
          @result = Services::Accounts::CreateAccountService.new(account_id: account_id, balance: amount).perform
          return self
        end
        @result = Services::Accounts::DepositToAccountService.new(account_id: account_id, amount: amount).perform
        self
      end

      def response
        res = {
          status: @result['response_status'],
          message: {
            destination:
            {
              id: account_id.to_s,
              balance: Account.find_by(id:account_id).balance
            }
        } }
        Hashie::Mash.new(res)
      end
    end
  end
end