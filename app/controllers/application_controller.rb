class ApplicationController < ActionController::API
  ACCEPTABLE_FORMATS = ['xlsx', 'json']

  before_action :check_format unless Rails.env.test?

  protected

  def check_format
    admit_format = ACCEPTABLE_FORMATS.include?(params[:format])
    admit_headers = ACCEPTABLE_FORMATS.grep(/#{request.headers['Accept']}/)

    return admit_format  || admit_headers

    render json: 'application must accept json format', status: :not_acceptable
  end
end
