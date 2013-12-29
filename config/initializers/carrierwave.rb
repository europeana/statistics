CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        
    :aws_access_key_id      => AWS_ACCESS_KEY_ID,            
    :aws_secret_access_key  => AWS_SECRET_ACCESS_KEY,                        
    :region                 => 'ap-southeast-1'#,
    #:endpoint=>'http://pykhub-cms-images-dev.s3-website-ap-southeast-1.amazonaws.com/'
  }
  config.fog_directory  = AWS_S3_BUCKET
  config.fog_public     = false                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

