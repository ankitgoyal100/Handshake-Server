class Phone < ActiveRecord::Base
  
  belongs_to :card
  
  phony_normalize :number
  
  validates_plausible_phone :number, presence: true
  validates :country_code, presence: true

end
