CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => "AKIAJHOEFVSVRUEFNORA",
      :aws_secret_access_key  => "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"
      # :region                 => ENV['S3_REGION'] # Change this for different AWS region. Default is 'us-east-1'
  }
  config.fog_directory  = "handshake"
end