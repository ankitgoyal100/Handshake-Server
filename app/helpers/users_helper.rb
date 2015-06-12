module UsersHelper
  
  def json_account(json, user)
    json.id user.id
    json.created_at user.created_at
    json.updated_at user.updated_at
    json.email user.email
    json.first_name user.first_name
    json.last_name user.last_name
    json.picture user.picture.url
    json.thumb user.picture.thumb.url
    json.cards user.cards do |card|
      json_card(json, card)
    end
  end
  
  def json_user(json, user)
    json.id user.id
    json.created_at user.created_at
    json.updated_at user.updated_at
    json.first_name user.first_name
    json.last_name user.last_name
    json.picture user.picture.url
    json.thumb user.picture.thumb.url
    json.contacts user.contacts.length
    json.mutual (user.contacts & current_user.contacts).length
    if current_user.contacts.include?(user)
      friendship = current_user.friendships.find_by(contact: user)
      json.is_contact true
      json.cards friendship.cards do |card|
        json_card(json, card)
      end
      json.request_sent false
      json.request_received false
    else
      json.is_contact false
      json.request_sent !user.friendships.find_by(contact: current_user, accepted: false).nil?
      json.request_received !current_user.friendships.find_by(contact: user, accepted: false).nil?
    end
  end
  
end
