if not @errors.nil?
  json.errors @errors
else
	json.auth_token @user.authentication_token
  json.user do |json|
    json_account(json, @user)
  end
end