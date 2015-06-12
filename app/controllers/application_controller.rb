class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  
  def authenticate_user_from_token!
    user_id = params[:user_id].presence
    user = user_id && User.find_by_id(user_id)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:auth_token])
      sign_in user, store: false
    else
      render :status => 401, :json => { errors: ['You are not authorized to that'] }
    end
  end
  
end
