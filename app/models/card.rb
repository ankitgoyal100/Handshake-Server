class Card < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :emails, dependent: :destroy
  has_many :phones, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :socials, dependent: :destroy
  
  accepts_nested_attributes_for :emails
  accepts_nested_attributes_for :phones
  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :socials
  
  has_and_belongs_to_many :friendships
  has_and_belongs_to_many :group_members
  
  validates :name, presence: true
  
end
