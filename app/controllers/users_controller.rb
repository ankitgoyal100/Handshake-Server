class UsersController < ApplicationController
  
  before_filter :authenticate_user_from_token!, except: [ :create ]
  
  def show
    @user = User.find_by_id(params[:id])
    if @user == nil
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
  end
  
  def account
  end
  
  def create
    @user = User.new(params.permit(:email, :password, :first_name, :last_name, :picture))
    if not @user.save
      @errors = @user.errors.full_messages
      render status: 422
      return
    end
    
    # create personal card
    card = Card.create(user: @user, name: "Personal")
    @user.cards << card
    @user.notifications_settings = NotificationsSettings.create
  end
  
  def update
    @user = current_user
    @user.assign_attributes(params.permit(:email, :first_name, :last_name, :picture))
    # if @user.email == params[:email]
#       @user.unconfirmed_email = nil
#     end
    if not @user.save
      @errors = @user.errors.full_messages
      render status: 422
      return
    end
    
    # update contacts
    
    @user.friendships.each do |friendship|
      friendship.touch
      friendship.save
    end
  end
  
  def destroy
    user = current_user
    user.destroy
  end
  
  def contacts
    user = User.find_by_id(params[:id])
    if user == nil
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    @contacts = user.contacts.where.not(id: current_user.id)
  end
  
  def mutual
    user = User.find_by_id(params[:id])
    if user == nil
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    @mutual = user.contacts & current_user.contacts
  end
  
  def update_location
    if not params[:lat] or not params[:lng]
      @errors = [ 'You must specify a location (lat, lng) ']
      render status: 422
      return
    end
    
    current_user.lat = params[:lat]
    current_user.lng = params[:lng]
    current_user.save
  end
  
end
