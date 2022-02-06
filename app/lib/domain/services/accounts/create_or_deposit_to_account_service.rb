module Services
  module Accounts

    class CreateOrDepositToAccountService
      attr_reader :account_id, :amount, :result
      def initialize(account_id:, amount:0)
        @account_id = account_id
        @amount = amount
        @result = {}
      end

      def perform
        return result unless validate!
        if Account.find_by(id:account_id)
          result = Services::Accounts::DepositToAccountService.new(account_id:account_id, amount:amount).perform
        else
          result = Services::Accounts::CreateAccountService.new(account_id:account_id, balance:amount).perform
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
