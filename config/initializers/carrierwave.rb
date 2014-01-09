CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        
    :aws_access_key_id      => AWS_ACCESS_KEY_ID,            
    :aws_secret_access_key  => AWS_SECRET_ACCESS_KEY,                        
    :region                 => AWS_REGION,
    :endpoint               => AWS_ENDPOINT
  }
  config.fog_directory  = AWS_S3_BUCKET
  config.fog_public     = true
end