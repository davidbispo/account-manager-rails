class EventsController < ApplicationController
  def create
    return render json: {
      "destination" =>
        { "id" => params[:destination],
          "balance" => params[:amount].to_f
        }
    }, status: :created
  end
end