if not @errors.nil?
  json.errors @errors
else
  json.user do |json|
    json_user(json, @user)
  end
end