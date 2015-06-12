if not @errors.nil?
  json.errors @errors
else
  json.group do |json|
    json.id @group.id
    json.created_at @group.created_at
    json.updated_at @group.updated_at
    json.name @group.name
    json.code @group.code
    json.members @group.users.where.not(id: current_user.id) do |user|
      json_user(json, user)
    end
  end
end