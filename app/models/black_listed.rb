class BlackListed < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :black_listed_user, class_name: 'User'
  
end
