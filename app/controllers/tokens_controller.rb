class TokensController < ApplicationController
  
  def create
    email = params[:email]
    password = params[:password]
    
    @user = User.find_by_email(email.downcase)
    
    if @user == nil
      @errors = [ "Invalid email or password" ]
      render status: 401
      return
    end
    
    if @user.valid_password? password
      if not @user.authentication_token
        @user.generate_token
        
        if not @user.save
          @errors = [ "Could not create a valid token" ]
          render status: 500
        end
      end
    else
      @errors = [ "Invalid email or password" ]
      render status: 401
    end
  end
  
  def destroy
    @user = User.find_by_authentication_token(params[:id])
    if @user.nil?
      @errors = [ "Invalid token" ]
      render status: 404
    else
      @user.authentication_token = nil
      @user.save
    end
  end
  
end
