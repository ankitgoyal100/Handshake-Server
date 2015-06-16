require 'carrierwave/orm/activerecord'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  validates :first_name, presence: true
  
  has_many :cards
  
  has_many :friendships
  has_many :contacts, -> { where(friendships: { accepted: true, is_deleted: false }).order('first_name DESC') }, through: :friendships

  has_many :group_members
  has_many :groups, through: :group_members
  
  has_many :feed_items
  
  has_and_belongs_to_many :contact_data_entries
  
  mount_uploader :picture, PictureUploader
         
  def generate_token
    self.authentication_token = loop do
      random_token = rand(36**32).to_s(36)
      break random_token unless User.find_by_authentication_token(random_token)
    end
  end
  
  def formatted_name
    if not self.last_name.nil? and self.last_name.length > 0
      self.first_name + " " + self.last_name
    else
      self.first_name
    end
  end
  
  include Tanker
  
  tankit 'users_index' do
    
    indexes :id
    
    indexes :name do
      if self.first_name and self.last_name
        self.first_name + " " + self.last_name
      else
        self.first_name
      end
    end
    
    indexes :phones do # numbers are indexed with spaces between each digit
      self.cards.map { |card| card.phones.map { |phone| phone.number.gsub(/[^0-9]/, "").gsub(/(.{1})(?=.)/, '\1 \2') }}.flatten.uniq
    end
    
    indexes :emails do
      self.cards.map { |card| card.emails.map { |email| email.address }}.flatten.uniq
    end
    
    variables do
      {
        0 => self.lat,
        1 => self.lng
      }
    end
    
    functions do
      {
        1 => "rel / if(d[0] == -1000, 100, if(q[0] == -1000, 100, max(0.000001, min(100, miles(d[0], d[1], q[0], q[1])))))"
      }
    end
    
  end
  
  after_save :update_tank_indexes
  after_destroy :delete_tank_indexes
  
  def self.per_page
    100
  end
         
end
