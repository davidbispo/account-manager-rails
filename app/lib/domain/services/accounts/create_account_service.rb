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
            result['response_status'] = 201
            result['status'] = 'success'
            result['message'] = 'Account creation successful'
          end
        rescue ActiveRecord::RecordNotUnique => e
          result['response_status'] = 409
          result['status'] = 'failed'
          result['message'] = 'Account already exists'
        rescue Exception => e
          #send to monitoring
          result['response_status'] = 422
          result['status'] = 'failed'
          result['message'] = 'Account creation failed'
        end
        result
      end

      def validate!
        begin
          return account_id.to_i.is_a?(Integer) &&
            balance.to_f.is_a?(Float)
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
