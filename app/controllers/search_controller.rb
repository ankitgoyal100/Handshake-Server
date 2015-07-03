class SearchController < ApplicationController
  
  before_filter :authenticate_user_from_token!
  
  def index
    if not params[:q]
      @results = []
    else
      params[:q] = params[:q].downcase
      search_results = User.__elasticsearch__.search( {
        query: {
          bool: {
            must: [
              {
                multi_match: { fields: [:first_name, :last_name, :full_name], query: params[:q], type: :phrase_prefix }
              }
            ],
            must_not: [
              {
                ids: { values: [current_user.id] }
              }
            ]
          }
        },
        sort: [ 
          {
            _geo_distance: {
              location: {
                lat: current_user.lat,
                lon: current_user.lng
              },
              order: "asc",
              unit: "km"
            }
          } 
        ]
      }).page(params[:page]).records
      #search_results = User.search_tank("name:(" + params[:q].split(" ").join("* ") + "*" + ")", var0: current_user.lat, var1: current_user.lng, function: 1, conditions: { '-id' => current_user.id }, page: params[:page])
      @results = []
      @current_user_contacts = current_user.contacts.to_a
      
      # map users to friendships
      user_friendship_map = {}
      Friendship.where(contact: current_user, user_id: search_results.map { |r| r.id }).each { |f| user_friendship_map[f.user] = f } # outgoing friendships
      current_user.friendships.where(contact_id: search_results.map { |r| r.id }).each { |f| user_friendship_map[f.contact] = f } # incoming overwrite
      
      # load black list
      black_list = current_user.black_listed_users.to_a
      
      search_results.each do |search_result|
        result = {}
        result[:user] = search_result
        result[:contacts] = search_result.contacts.where.not(id: current_user.id).count
        result[:mutual] = search_result.contacts.where(id: @current_user_contacts.map { |c| c.id }).count # mutual contacts
        
        friendship = user_friendship_map[search_result]
        
        if friendship and friendship.accepted and not friendship.is_deleted
          result[:friendship] = friendship
          result[:cards] = friendship.cards
        else
          result[:is_contact] = false
          result[:request_sent] = friendship and friendship.user == search_result and not friendship.accepted
          result[:request_received] = friendship and friendship.user == current_user and not friendship.accepted
        end
        
        result[:notifications] = !black_list.include?(search_result)
        
        @results << result
      end
      @results = @results.sort_by { |result| [-result[:mutual], @results.index(result)] }
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
