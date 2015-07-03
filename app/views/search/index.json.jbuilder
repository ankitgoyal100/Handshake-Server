json.results @results do |result|
  user = result[:user]
  json.id user.id
  json.created_at user.created_at
  json.updated_at user.updated_at
  json.first_name user.first_name
  json.last_name user.last_name
  json.picture user.picture.url
  json.thumb user.picture.thumb.url
  json.contacts result[:contacts]
  json.mutual result[:mutual]
  if result[:friendship]
    json.is_contact true
    json.cards result[:cards] do |card|
      json_card(json, card)
    end
    json.contact_updated result[:friendship].updated_at
    json.request_sent false
    json.request_received false
  else
    json.is_contact false
    json.request_sent result[:request_sent]
    json.request_received result[:request_received]
  end
  json.notifications result[:notifications]
end