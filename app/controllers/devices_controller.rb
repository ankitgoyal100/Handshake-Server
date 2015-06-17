class DevicesController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def create
    if not params[:token] or not params[:platform]
      @errors = [ 'You must specifiy a token and platform (iphone, android)' ]
      render status: 422
      return
    end
    
    token = params[:token].downcase
    platform = params[:platform].downcase
    
    device = Device.find_or_create_by(token: token, platform: platform)
    current_user.devices << device
  end
  
end
