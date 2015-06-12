class GroupMember < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :group
  
  has_and_belongs_to_many :cards
  
  self.per_page = 200
  
end
