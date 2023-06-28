module Strategies
  module Events
    class TransferStrategy < Strategies::Events::EventProcessorStrategy
      attr_accessor :origin_account_id, :destination_account_id, :amount, :result

      def self.should_run_for?(event)
        event == 'transfer'
      end

      def initialize(args)
        @origin_account_id = args["origin"]
        @destination_account_id = args["destination"]
        @amount = args["amount"]
      end

      def execute
        @result = Services::Accounts::TransferBetweenAccountsService.new(
          origin_account_id: origin_account_id,
          destination_account_id: destination_account_id,
          amount: amount,
        ).perform
        self
      end

      def response
        if result['status'] == 'failed'
          res = { status: 404, message: '0' }
        else
          res = {
            status: @result['response_status'],
            message: {
              origin: {
                id: origin_account_id.to_s,
                balance: Account.find(origin_account_id).balance
              },
              destination:
                { id: destination_account_id.to_s,
                  balance: Account.find(destination_account_id).balance
                }
            } }
        end
        Hashie::Mash.new(res)
      end
    end
  end
end