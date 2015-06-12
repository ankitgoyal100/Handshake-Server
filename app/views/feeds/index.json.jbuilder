json.feed @feed_items do |item|
  json.id item.id
  json.created_at item.created_at
  json.updated_at item.updated_at
  if item.contact.nil?
    json.user nil
  else
    json.user do |json|
      json_user(json, item.contact)
    end
  end
  if item.group.nil?
    json.group nil
  else
    group = item.group
    json.group do |json|
      json.id group.id
      json.created_at group.created_at
      json.updated_at group.updated_at
      json.name group.name
      json.code group.code
    end
  end
  json.item_type item.item_type
end