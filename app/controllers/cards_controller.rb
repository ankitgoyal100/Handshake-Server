class CardsController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    @cards = current_user.cards
  end
  
  def show
    @card = Card.find_by_id(params[:id])
    if @card == nil or @card.user_id != current_user.id
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
    end
  end
  
  def create
    @card = Card.new(params.permit(:name, emails_attributes: [:address, :label], phones_attributes: [:number, :label, :country_code], addresses_attributes: [:street1, :street2, :city, :state, :zip, :country, :label], socials_attributes: [:username, :network]))
    @card.user = current_user
    if not @card.save
      @errors = @card.errors.full_messages
      render status: 422
      return
    end
  end
  
  def update
    @card = Card.find_by_id(params[:id])
    if @card == nil or @card.user_id != current_user.id
      @errors = [ 'Fuck off' ]
      render status: 401
      return
    end
    
    old_phones = []
    old_emails = []
    old_addresses = []
    old_socials = []
    
    # clear old phones, emails, addresses, and socials
    @card.phones.each { |phone| old_phones << phone }
    @card.emails.each { |email| old_emails << email }
    @card.addresses.each { |address| old_addresses << address }
    @card.socials.each { |social| old_socials << social }
    
    @card.assign_attributes(params.permit(:name, emails_attributes: [:address, :label], phones_attributes: [:number, :label, :country_code], addresses_attributes: [:street1, :street2, :city, :state, :zip, :country, :label], socials_attributes: [:username, :network]))
  
    @card.touch
    if not @card.valid?
      @errors = @card.errors.full_messages
      render status: 422
      return
    end
    
    @card.phones -= old_phones
    @card.emails -= old_emails
    @card.addresses -= old_addresses
    @card.socials -= old_socials
    @card.save
    
    # update friendships / create feed items
    
    feed_items = []
    
    @card.friendships.each do |friendship|
      friendship.touch
      friendship.save
      
      feed_items << FeedItem.new(user: friendship.user, contact: current_user, item_type: "card_updated")
    end
    
    FeedItem.transaction do
      feed_items.each { |item| item.save }
    end
 
    # send notifications
  end
  
end
