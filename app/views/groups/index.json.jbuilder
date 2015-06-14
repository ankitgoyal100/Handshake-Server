json.groups @groups do |group|
  json.id group.id
  json.created_at group.created_at
  json.updated_at group.updated_at
  json.name group.name
  json.code group.code
end