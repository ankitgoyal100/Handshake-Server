class ContactsController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    if (params[:since_date])
      date = Date.parse(params[:since_date])
      @contacts = current_user.friendships.where("accepted = 't' AND updated_at > ?", date).page(params[:page]).order('created_at DESC').map { |f| f.contact }
    else
      @contacts = current_user.friendships.where(accepted: true).page(params[:page]).order('created_at DESC').map { |f| f.contact }
    end
  end
  
  def destroy
    @user = User.find_by_id(params[:id])
    if @user == nil or not current_user.contacts.include?(@user)
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    friendship = current_user.friendships.find_by(contact: @user)
    
    friendship.is_deleted = true
    friendship.save
    
    # delete feed items
    FeedItem.where(user: current_user, contact: @user, item_type: "new_contact").destroy_all
    FeedItem.where(user: current_user, contact: @user, item_type: "card_updated").destroy_all
    
    # delete inverse friendship
    friendship = Friendship.find_by(user: @user, contact: current_user)
    friendship.is_deleted = true
    friendship.save
    
    # delete feed items
    FeedItem.where(user: @user, contact: current_user, item_type: "new_contact").destroy_all
    FeedItem.where(user: @user, contact: current_user, item_type: "card_updated").destroy_all
  end
  
end
