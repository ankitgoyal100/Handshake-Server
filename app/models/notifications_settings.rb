class NotificationsSettings < ActiveRecord::Base
  
  belongs_to :user
  
  before_save :default_values
  def default_values
    self.enabled = true if self.enabled.nil?
    self.requests = true if self.requests.nil?
    self.new_contacts = true if self.new_contacts.nil?
    self.new_group_members |= true if self.new_group_members.nil?
    self.new_contact_information = true if self.new_contact_information.nil?
    self.contact_joined = true if self.contact_joined.nil?
    self.suggestions = true if self.suggestions.nil?
    self.new_features = true if self.new_features.nil?
    self.offers = true if self.offers.nil?
    true
  end
  
end
