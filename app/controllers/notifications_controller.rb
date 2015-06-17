class NotificationsController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def show_settings
    @settings = current_user.notifications_settings
  end
  
  def update_settings
    @settings = current_user.notifications_settings
    
    @settings.enabled = params[:enabled]
    @settings.requests = params[:requests]
    @settings.new_contacts = params[:new_contacts]
    @settings.new_group_members = params[:new_group_members]
    @settings.new_contact_information = params[:new_contact_information]
    @settings.contact_joined = params[:contact_joined]
    @settings.suggestions = params[:suggestions]
    @settings.new_features = params[:new_features]
    @settings.offers = params[:offers]
    
    @settings.save
  end
  
  def black_list_add
    @user = User.find_by_id(params[:id])
    if @user == nil or @user == current_user
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    BlackListed.find_or_create_by(user: current_user, black_listed_user: @user)
  end
  
  def black_list_remove
    @user = User.find_by_id(params[:id])
    if @user == nil or @user == current_user
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    BlackListed.where(user: current_user, black_listed_user: @user).destroy_all
  end
  
  def black_list
    @black_list = current_user.black_listed_users
  end
  
end
