class Friendship < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :contact, class_name: 'User'
  
  has_and_belongs_to_many :cards
  
  before_save :default_values
  def default_values
    self.accepted ||= false
    self.is_deleted ||= false
    true
  end
  
end
