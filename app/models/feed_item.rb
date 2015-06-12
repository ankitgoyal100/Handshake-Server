class FeedItem < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :contact, class_name: 'User'
  belongs_to :group
  
  def self.per_page
    100
  end
  
end
