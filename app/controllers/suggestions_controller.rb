class SuggestionsController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    @suggestions = []
    
    current_user.contact_data_entries.each do |entry|
      if entry.phone
        Phone.where(number: entry.phone).each do |phone|
          if phone
            user = phone.card.user
            @suggestions << user if user != current_user and not Friendship.find_by(user: current_user, contact: user) and not Friendship.find_by(user: user, contact: current_user)
          end
        end
      elsif entry.email
        Email.where(address: entry.email).each do |email|
          if email
            user = email.card.user
            @suggestions << user if user != current_user and not Friendship.find_by(user: current_user, contact: user) and not Friendship.find_by(user: user, contact: current_user)
          end
        end
        User.where(email: entry.email) do |user|
          @suggestions << user if user != current_user and not Friendship.find_by(user: current_user, contact: user) and not Friendship.find_by(user: user, contact: current_user)
        end
      end
    end
    
    @suggestions = @suggestions.uniq
  end
  
end
