module Services
  module Accounts
    class TransferBetweenAccountsService
      attr_reader :origin_account_id, :destination_account_id,
                  :amount, :origin_account, :destination_account,
                  :result
      def initialize(origin_account_id:, destination_account_id:, amount:)
        @origin_account_id = origin_account_id
        @destination_account_id = destination_account_id
        @amount = amount
        @result = {}
      end

      def perform
        return result unless validate!

        @origin_account = Account.find_by(id:origin_account_id)
        @destination_account = Account.find_by(id:destination_account_id)

        if origin_account.blank? || destination_account.blank?
          result['status'] = 422
          result['message'] = 'Invalid accounts parameter set'
          return result
        end
        ActiveRecord::Base.transaction do
          new_balances = get_new_balances_after_deposit
          origin_account.update(balance:new_balances.origin)
          destination_account.update(balance:new_balances.destination)
          result['status'] = 200
          result['message'] = 'Transfer successful'
        rescue ActiveRecord::Rollback => e
          #Send to monitoring
          result['status'] = 500
          result['message'] = 'Transfer failed'
        end
        result
      end

      def get_new_balances_after_deposit
        new_balance_on_origin = origin_account.balance - amount
        new_balance_on_dest = destination_account.balance + amount
        Hashie::Mash.new( { origin: new_balance_on_origin, destination: new_balance_on_dest })
      end

      def validate!
        begin
          return origin_account_id.to_i.is_a?(Integer) &&
            destination_account_id.to_i.is_a?(Integer) &&
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