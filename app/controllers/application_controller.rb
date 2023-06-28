class ApplicationController < ActionController::API
  ACCEPTABLE_FORMATS = ['xlsx', 'json']

  before_action :check_format unless Rails.env.test?

  protected

  def check_format
    admit_format = ACCEPTABLE_FORMATS.include?(params[:format])
    return if admit_format
    return render plain: 'application must accept json format', status: :not_acceptable
  end
end
