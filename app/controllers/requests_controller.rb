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
