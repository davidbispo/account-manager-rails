class EventsController < ApplicationController
  def create
    result = Services::Events::ResolveEventService.new(
      event_type: permitted_params_create[:type],
      request_params: permitted_params_create.except(:event_type)
    ).resolve
    render json: result.message, status: result.status
  end

  def permitted_params_create
    params.permit(:type,:amount, :account_id, :destination, :origin)
  end
end