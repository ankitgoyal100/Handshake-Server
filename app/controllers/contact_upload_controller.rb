class ContactUploadController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def upload_phones
    if not params[:phones]
      @errors = [ 'You must specify phone numbers in international format' ]
      render status: 422
      return
    end
    
    params[:phones].each do |number|
      if PhonyRails.plausible_number?(number)
        normalized_number = PhonyRails.normalize_number(number)
        
        entry = ContactDataEntry.find_or_create_by(phone: normalized_number)
        entry.users << current_user
      end
    end
  end
  
  def upload_emails
    if not params[:emails]
      @errors = [ 'You must specify emails' ]
      render status: 422
      return
    end
    
    params[:emails].each do |email|
      entry = ContactDataEntry.find_or_create_by(email: email)
      entry.users << current_user
    end
  end
  
end
