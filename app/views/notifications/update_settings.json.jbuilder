if not @errors.nil?
  json.errors @errors
else
  json.settings do |json|
    json_notifications_settings(json, @settings)
  end
end