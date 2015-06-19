if Rails.env.production?
  User.__elasticsearch__.client = Elasticsearch::Client.new host: ENV['SEARCHBOX_URL']
end