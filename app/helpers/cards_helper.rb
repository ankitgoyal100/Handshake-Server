module CardsHelper
  
  def json_card(json, card)
    json.id card.id
    json.created_at card.created_at
    json.updated_at card.updated_at
    json.name card.name
  	json.emails card.emails do |email|
      json.address email.address
      json.label email.label
    end
    json.phones card.phones do |phone|
      json.number phone.number
      json.label phone.label
      json.country_code phone.country_code
    end
    json.addresses card.addresses do |address|
      json.street1 address.street1
      json.street2 address.street2
      json.city address.city
      json.state address.state
      json.zip address.zip
      json.country address.country
      json.label address.label
    end
    json.socials card.socials do |social|
      json.username social.username
      json.network social.network
    end
  end
  
end
