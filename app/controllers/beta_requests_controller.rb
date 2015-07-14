class BetaRequestsController < ApplicationController
  
  def create
    if not params[:email] or params[:email] === "" or not params[:device]
      @errors = true
      render 'static_pages/home'
      return
    end
    
    @request = BetaRequest.find_or_create_by(params.permit(:email, :device))
    @request.save
  end
  
end
