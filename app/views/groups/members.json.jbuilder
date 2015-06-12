if not @errors.nil?
  json.errors @errors
else
  json.members @members do |user|
    json_user(json, user)
  end
end