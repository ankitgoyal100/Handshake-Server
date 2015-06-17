module NotificationsHelper
  
  def json_notifications_settings(json, settings)
    json.enabled settings.enabled
    json.requests settings.requests
    json.new_contacts settings.new_contacts
    json.new_group_members settings.new_group_members
    json.new_contact_information settings.new_contact_information
    json.contact_joined settings.contact_joined
    json.suggestions settings.suggestions
    json.new_features settings.new_features
    json.offers settings.offers
  end
  
end
