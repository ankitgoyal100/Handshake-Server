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
  
  has_many :devices
  has_one :notifications_settings
  
  has_many :black_listeds
  has_many :black_listed_users, through: :black_listeds
  
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
  
  def notifications_json_for_user(user)
    json = {}
    json[:id] = self.id
    json[:created_at] = self.created_at
    json[:updated_at] = self.updated_at
    json[:first_name] = self.first_name
    json[:last_name] = self.last_name
    json[:picture] = self.picture.url
    json[:thumb] = self.picture.thumb.url
    json[:contacts] = self.contacts.length
    json[:mutual] = (self.contacts & user.contacts).length
    if user.contacts.include?(self)
      friendship = user.friendships.find_by(contact: self)
      json[:is_contact] = true
      json[:cards] = friendship.cards.map do |card|
        { id: card.id, created_at: card.created_at, updated_at: card.updated_at,
          phones: card.phones.map { |phone| { number: phone.number, label: phone.label, country_code: phone.country_code } },
          emails: card.emails.map { |email| { address: email.address, label: email.label } },
          addresses: card.addresses.map { |address| { street1: address.street1, street2: address.street2, city: address.city, state: address.state, zip: address.zip, country: address.country, label: address.label } },
          socials: card.socials.map { |social| { username: social.username, network: social.network } }
        }
      end
      json[:contact_updated] = friendship.updated_at
      json[:request_sent] = false
      json[:request_received] = false
    else
      json[:is_contact] = false
      json[:request_sent] = !self.friendships.find_by(contact: user, accepted: false).nil?
      json[:request_received] = !user.friendships.find_by(contact: self, accepted: false).nil?
    end
    json[:notifications] = !user.black_listed_users.include?(self)
    json
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
