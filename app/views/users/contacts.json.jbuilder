if not @errors.nil?
  json.errors @errors
else
  json.contacts @contacts do |contact|
    json_user(json, contact)
  end
end