module Services
  module Accounts

    class CreateAccountService
      attr_reader :account_id, :balance, :result
      def initialize(account_id:, balance:)
        @account_id = account_id
        @balance = balance
        @result = {}
      end

      def perform
        return result unless validate!
        begin
          if Account.create!(id:account_id, balance:balance)
            result['status'] = 201
            result['message'] = 'Account creation successful'
          end
        rescue ActiveRecord::RecordNotUnique => e
          result['status'] = 409
          result['message'] = 'Account already exists'
        rescue Exception => e
          #send to monitoring
          result['status'] = 422
          result['message'] = 'Account creation failed'
        end
        result
      end

      def validate!
        begin
          return account_id.to_i.is_a?(Integer) &&
            balance.to_f.is_a?(Float)
        rescue Exception => e
          result['status'] = 422
          result['message'] = 'Incorrect parameter set'
          false
        end
      end
    end
  end
end
