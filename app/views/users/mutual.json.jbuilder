if not @errors.nil?
  json.errors @errors
else
  json.mutual @mutual do |contact|
    json_user(json, contact)
  end
end