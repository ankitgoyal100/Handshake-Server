if not @errors.nil?
  json.errors @errors
else
  json.requests @requests do |user|
    json_user(json, user)
  end
end