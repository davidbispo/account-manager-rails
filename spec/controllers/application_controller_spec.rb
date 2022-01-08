require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    before_action :check_format

    def index
      render text: 'Ok'
    end
  end

  describe "#check_format" do
    context "with json" do
      it "should respond with nil when format is json" do
        get :index, format: 'json'
        expect(response.body).to eq("Ok")
      end

      it "should respond with nil when format is json" do
        request.headers['Accept'] = 'json'
        get :index
        expect(response.body).to eq('Ok')
      end
    end

    context "without json" do
      xit "should respond with not_acceptable http code" do
        get :index, format: 'xml'
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end
end
