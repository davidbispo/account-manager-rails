module Services
  module Accounts

    class WithdrawFromAccountService
      attr_reader :account_id, :amount, :result

      def initialize(account_id:, amount:)
        @account_id = account_id
        @amount = amount
        @result = {}
      end

      def perform
        return result unless validate!
        account = Account.find_by(id: account_id)
        if account.blank?
          result['response_status'] = 404
          result['message'] = 'Account not found'
          result['status'] = 'failed'
          return result
        else
          ActiveRecord::Base.transaction do
            new_balance = account.balance - amount
            account.update(balance: new_balance)
            result['response_status'] = 200
            result['message'] = 'Withdrawal successful'
            result['status'] = 'success'
          rescue ActiveRecord::Rollback => e
            result['response_status'] = 422
            result['message'] = 'Withdrawal failed'
            result['status'] = 'failed'
            return result
            # Send to monitoring
          end
        end
        result
      end

      def validate!
        begin
          return account_id.to_i.is_a?(Integer) &&
            amount.to_f.is_a?(Float)
        rescue Exception => e
          result['response_status'] = 422
          result['message'] = 'Incorrect parameter set'
          result['status'] = 'failed'
          false
        end
      end
    end
  end
end
