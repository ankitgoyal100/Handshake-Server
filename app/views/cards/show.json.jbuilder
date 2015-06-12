if not @errors.nil?
  json.errors @errors
else
  json.card do |json|
    json_card(json, @card)
  end
end