if not @errors.nil?
  json.errors @errors
else
  json.locations @updates do |update|
    json_location_update(json, update)
    json.distance @distances[@updates.find_index(update)]
  end
end