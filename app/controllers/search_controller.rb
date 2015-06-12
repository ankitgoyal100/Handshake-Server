class SearchController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    if not params[:q]
      @results = []
    else
      search_results = User.search_tank("name:(" + params[:q].split(" ").join("* ") + "*" + ")", var0: current_user.lat, var1: current_user.lng, function: 1, conditions: { '-id' => current_user.id }, page: params[:page])
      @results = []
      search_results.each do |search_result|
        result = []
        result << search_result
        result << (search_result.contacts & current_user.contacts).length
        @results << result
      end
      @results = @results.sort_by { |result| [-result[1], @results.index(result)] }
    end
  end
  
  def suggestions
    if not params[:phones] and not params[:emails]
      @results = []
      return
    end
    
    exempt_user_ids = current_user.contacts.map { |contact| contact.id } + [current_user.id]
    @results = []
    
    if params[:phones]
      # strip phones of characters and put a space between each number and surround by quotes
      phones = params[:phones].map { |phone| "\"" + phone.gsub(/[^0-9]/, "").gsub(/(.{1})(?=.)/, '\1 \2') + "\"" }
      
      # search by 100 phones at a time
      curr_search_list = []
      i = 0
      while i < phones.length
        curr_search_list << phones[i]
        
        if curr_search_list.length == 30 or i == phones.length - 1
          search_results = User.search_tank("phones:(" + curr_search_list.join(" OR ") + ")", conditions: { '-id' => exempt_user_ids })
          @results += search_results.map do |search_result|
            result = []
            result << search_result
            result << (search_result.contacts & current_user.contacts).length
            result
          end
          exempt_user_ids += search_results.map { |user| user.id } # exempt these users from next search
          curr_search_list = []
        end
        
        i += 1
      end
    end
    
    if params[:emails]
      emails = params[:emails]
      
      # search by 100 emails at a time
      curr_search_list = []
      i = 0
      while i < emails.length
        curr_search_list << emails[i]
        
        if curr_search_list.length == 30 or i == emails.length - 1
          search_results = User.search_tank("emails:(" + curr_search_list.join(" OR ") + ")", conditions: { '-id' => exempt_user_ids })
          @results += search_results.map do |search_result|
            result = []
            result << search_result
            result << (search_result.contacts & current_user.contacts).length
            result
          end
          exempt_user_ids += search_results.map { |user| user.id } # exempt these users from next search
          curr_search_list = []
        end
        
        i += 1
      end
      
      
    end
  end
  
end
