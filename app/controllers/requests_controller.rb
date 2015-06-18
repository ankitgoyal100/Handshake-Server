class RequestsController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    @requests = current_user.friendships.where(accepted: false).map { |f| f.contact }
  end
  
  def create
    @user = User.find_by_id(params[:id])
    if @user == nil or @user == current_user
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    # check cards
    
    if params[:card_ids].nil?
      @errors = [ 'You must specifiy a card' ]
      render status: 422
      return
    end
    
    cards = params[:card_ids].map { |card_id| Card.find_by_id(card_id) }
    
    cards.each do |card|
      if card == nil or card.user != current_user
        @errors = [ 'You are not authorized to do that' ]
        render status: 401
        return
      end
    end
    
    friendship = Friendship.find_by(user: @user, contact: current_user, accepted: false)
    
    if not friendship
      friendship = Friendship.find_or_create_by(user: @user, contact: current_user)
      friendship.accepted = false
      friendship.save
    
      # send notification
      if @user.notifications_settings.enabled and @user.notifications_settings.requests and !@user.black_listed_users.include?(current_user)
        @user.devices.each do |device|
          if device.platform === "iphone"
            notification = Houston::Notification.new(device: device.token)
            notification.alert = current_user.formatted_name + " sent you a request!"
            notification.badge = 1
            notification.category = "requests"
            notification.sound = "default"
            notification.custom_data = { user: current_user.notifications_json_for_user(@user) }
            APN.push(notification)
          end
        end
      end
    end
    
    friendship.cards = cards
  end
  
  def destroy
    @user = User.find_by_id(params[:id])
    if @user == nil or @user == current_user
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    friendship = Friendship.find_by(user: @user, contact: current_user)
    
    if friendship
      if friendship.is_deleted
        friendship.accepted = true
        friendship.save
      elsif not friendship.accepted
        friendship.destroy
      end
    end
  end
  
  def accept
    @user = User.find_by_id(params[:id])
    if @user == nil or @user == current_user
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    # check cards
    
    if params[:card_ids].nil?
      @errors = [ 'You must specifiy a card' ]
      render status: 422
      return
    end
    
    cards = params[:card_ids].map { |card_id| Card.find_by_id(card_id) }
    
    cards.each do |card|
      if card == nil or card.user != current_user
        @errors = [ 'You are not authorized to do that' ]
        render status: 401
        return
      end
    end
    
    friendship = Friendship.find_by(user: current_user, contact: @user, accepted: false)
    
    if friendship
      friendship.accepted = true
      friendship.is_deleted = false
      friendship.save
      
      # create corresponding friendship
      friendship = Friendship.find_or_create_by(user: @user, contact: current_user)
      friendship.accepted = true
      friendship.is_deleted = false
      friendship.cards = cards
      friendship.save
      
      # create feed items
      FeedItem.create(user: current_user, contact: @user, item_type: "new_contact")
      FeedItem.create(user: @user, contact: current_user, item_type: "new_contact")
      
      # send notifications
      if @user.notifications_settings.enabled and @user.notifications_settings.new_contacts and !@user.black_listed_users.include?(current_user)
        @user.devices.each do |device|
          if device.platform === "iphone"
            notification = Houston::Notification.new(device: device.token)
            notification.alert = current_user.formatted_name + " accepted your request!"
            notification.badge = 1
            notification.category = "new_contacts"
            notification.sound = "default"
            notification.custom_data = { user: current_user.notifications_json_for_user(@user) }
            APN.push(notification)
          end
        end
      end
    end
  end
  
  def decline
    @user = User.find_by_id(params[:id])
    if @user == nil or @user == current_user
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    friendship = Friendship.find_by(user: current_user, contact: @user)
    
    if friendship
      if friendship.is_deleted
        friendship.accepted = true
        friendship.save
      elsif not friendship.accepted
        friendship.destroy
      end
    end
  end
  
end
