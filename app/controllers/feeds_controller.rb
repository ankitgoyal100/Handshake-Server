class FeedsController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    @feed_items = current_user.feed_items.page(params[:page]).order('created_at DESC')
  end
  
end
