module Strategies
  module Events
    class TransferStrategy < Strategies::Events::EventProcessorStrategy
      attr_accessor :origin_account_id, :destination_account_id, :amount, :result

      def self.should_run_for?(event)
        event == 'transfer'
      end

      def initialize(args)
        @origin_account_id = args["origin_account_id"]
        @destination_account_id = args["destination_account_id"]
        @amount = args["amount"]
        self
      end

      def resolve
        @result = Accounts::Services::TransferBetweenAccountsService.new(
          origin_account_id: origin_account_id,
          destination_account_id: destination_account_id,
          amount: amount,
        ).perform
        self
      end

      def response
        if result
          res = { status: 204, result: 'ok' }
        else
          res = { status: 500, result: 'error' }
        end
        Hashie::Mash.new(res)
      end
    end
  end
end