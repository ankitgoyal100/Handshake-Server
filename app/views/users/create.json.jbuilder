if not @errors.nil?
  json.errors @errors
else
  json.user do |json|
    json_account(json, @user)
  end
end