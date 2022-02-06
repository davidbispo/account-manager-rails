module Services
  module Accounts
    class DepositToAccountService
      attr_reader :account_id, :amount, :result
      def initialize(account_id:, amount:)
        @account_id = account_id
        @amount = amount
        @result = {}
      end

      def perform
        return result unless validate!
        ActiveRecord::Base.transaction do
          account = Account.find_by(id:@account_id)
          if account
            new_balance = account.balance + amount
            account.update(balance:new_balance)
            result['status'] = 200
            result['message'] = 'Deposit successful'
          else
            result['status'] = 404
            result['message'] = 'Account not found'
          end
        rescue ActiveRecord::Rollback => e
          #Send to monitoring
          result['status'] = 422
          result['message'] = 'Deposit failed'
        end
        result
      end

      def validate!
        begin
          return account_id.to_i.is_a?(Integer) &&
            amount.to_f.is_a?(Float)
        rescue Exception => e
          result['status'] = 422
          result['message'] = 'Incorrect parameter set'
          false
        end
      end
    end
  end
end