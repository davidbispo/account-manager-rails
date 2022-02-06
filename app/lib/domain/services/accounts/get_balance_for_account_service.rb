module Services
  module Accounts
    class GetBalanceForAccountService
      attr_reader :account_id, :result
      def initialize(account_id:)
        @account_id = account_id
        @result = {}
      end

      def perform
        return result unless validate!
        account = Account.find_by(id:account_id)
        if account
          result['status'] = 200
          result['balance'] = account.balance
        else
          result['status'] = 404
          result['message'] = 'Account not found'
        end
        result
      end

      def validate!
        begin
          return account_id.to_i.is_a?(Integer)
        rescue Exception => e
          result['status'] = 422
          result['message'] = 'Incorrect parameter set'
          false
        end
      end
    end
  end
end
