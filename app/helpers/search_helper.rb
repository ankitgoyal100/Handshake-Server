module SearchHelper
  
  def json_search_result(json, result)
    user = result[0]
    json.id user.id
    json.created_at user.created_at
    json.updated_at user.updated_at
    json.first_name user.first_name
    json.last_name user.last_name
    json.picture user.picture.url
    json.thumb user.picture.thumb.url
    json.contacts user.contacts.where.not(id: current_user.id).count
    json.mutual result[1]
    if current_user.contacts.include?(user)
      friendship = current_user.friendships.find_by(contact: user)
      json.is_contact true
      json.cards friendship.cards do |card|
        json_card(json, card)
      end
      json.contact_updated friendship.updated_at
      json.request_sent false
      json.request_received false
    else
      json.is_contact false
      json.request_sent user.friendships.where(contact: current_user, accepted: false).count == 1
      json.request_received current_user.friendships.where(contact: user, accepted: false).count == 1
    end
    json.notifications current_user.black_listed_users.where(id: user.id).count == 1
  end
  
end
