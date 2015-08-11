class GroupsController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    @groups = current_user.groups
  end
  
  def show
    @group = Group.find_by_id(params[:id])
    if @group == nil or not @group.users.include?(current_user)
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
    end
  end
  
  def find
    @group = Group.find_by_code(params[:code])
    if @group == nil
      @errors = [ 'Group not found' ]
      render status: 404
    end
    @members = @group.users.where.not(id: current_user.id).limit(6)
  end
  
  def members  
    group = Group.find_by_id(params[:id])
    if group == nil or not group.users.include?(current_user)
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
    else
      @members = group.users.page(params[:page]).where.not(id: current_user.id)
    end
  end
  
  def create
    if params[:card_ids].nil?
      @errors = [ 'You must specifiy a card' ]
      render status: 422
      return
    end
    
    cards = params[:card_ids].map { |card_id| Card.find_by_id(card_id) }
    
    # check cards
    cards.each do |card|
      if card == nil or card.user != current_user
        @errors = [ 'You are not authorized to do that' ]
        render status: 401
        return
      end
    end
    
    name = params[:name]
    if name == nil or name.length == 0
      @errors = [ 'You must enter a name' ]
      render status: 422
      return
    end
    
    code = loop do
      random_code = rand(36**6).to_s(36)
      break random_code unless Group.find_by_code(random_code) or random_code.length != 6
    end
    
    @group = Group.create(name: name, code: code)
    
    GroupMember.create(user: current_user, cards: cards, group: @group)
  end
  
  def update
    @group = Group.find_by_id(params[:id])
    if @group == nil or not @group.users.include?(current_user)
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    name = params[:name]
    if name and name.length == 0
      @errors = [ 'You must enter a name' ]
      render status: 422
      return
    end
    
    @group.name = name
    @group.save
  end
  
  def join
    if params[:card_ids].nil?
      @errors = [ 'You must specify a card' ]
      render status: 422
      return
    end
    
    cards = params[:card_ids].map { |card_id| Card.find_by_id(card_id) }
    
    # check cards
    cards.each do |card|
      if card == nil or card.user != current_user
        @errors = [ 'You are not authorized to do that' ]
        render status: 401
        return
      end
    end
    
    @group = Group.find_by_code(params[:code])
    if not @group
      @errors = [ 'Invalid join code' ]
      render status: 404
      return
    end
    
    member = GroupMember.find_or_create_by(user: current_user, group: @group)
    member.cards = cards
    member.save
    
    # create friendships
    @group.group_members.where.not(user_id: current_user.id).each do |member|
      # create friendship for joinee
      
      friendship = Friendship.find_or_create_by(user: current_user, contact: member.user)
      friendship.accepted = true
      friendship.is_deleted = false
      
      member.cards.each do |card|
        if not friendship.cards.include?(card)
          friendship.cards << card
        end
      end
      friendship.save
      
      # create friendship for member
      
      friendship = Friendship.find_or_create_by(user: member.user, contact: current_user)
      friendship.accepted = true
      friendship.is_deleted = false
      
      cards.each do |card|
        if not friendship.cards.include?(card)
          friendship.cards << card
        end
      end
      friendship.save
      
      # create feed item
      FeedItem.find_or_create_by(user: member.user, contact: current_user, group: @group, item_type: "new_group_member")
      
      # send notification
      if member.user.notifications_settings.enabled and member.user.notifications_settings.new_group_members and !member.user.black_listed_users.include?(current_user)
        member.user.devices.each do |device|
          if device.platform === "iphone"
            notification = Houston::Notification.new(device: device.token)
            notification.alert = current_user.formatted_name + " joined " + @group.name + "."
            notification.badge = 1
            notification.category = "new_group_members"
            notification.sound = "default"
            notification.content_available = true
            notification.custom_data = { user: current_user.notifications_json_for_user(member.user), group_id: @group.id }
            APN.push(notification)
          elsif device.platform === "android"
            data = { data:
              {
                message: current_user.formatted_name + " joined " + @group.name + ".",
                user: current_user.notifications_json_for_user(member.user),
                group_id: @group.id
              }
            }
            GCM.send([device.token], data)
          end
        end
      end
    end
    
    # update group
    @group.touch
    @group.save
    
    # create current user feed item
    FeedItem.find_or_create_by(user: current_user, group: @group, item_type: "group_joined")
  end
  
  def leave
    group = Group.find_by_id(params[:id])
    if group == nil or not group.users.include?(current_user)
      @errors = [ 'You are not authorized to do that' ]
      render status: 401
      return
    end
    
    GroupMember.find_by_user_id_and_group_id(current_user.id, group.id).destroy
    
    # delete current user feed items
    FeedItem.where(user: current_user, group: group).destroy_all
    
    if group.group_members.length == 0
      group.destroy
    else
      group.touch
      group.save
      
      # delete feed items for remaining members
      group.users.each do |user| 
        FeedItem.where(user: user, contact: current_user, group: group, item_type: "new_group_member").destroy_all
      end 
    end
  end
  
end
