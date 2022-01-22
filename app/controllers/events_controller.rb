class EventsController < ApplicationController
  def create
    response,status = Services::Events::ResolveEventService.new(params).resolve
    render json: response, status: status
  end
end