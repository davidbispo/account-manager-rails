class AccountsController < ApplicationController
  def get_balance
    result = Services::Accounts::GetBalanceForAccountService.new(account_id: permitted_params[:id]).perform
    render json: result.balance, status: result.response_status
  end

  def permitted_params
    params.permit(:id)
  end
end