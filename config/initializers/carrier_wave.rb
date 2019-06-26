if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['S3_ACCESS_KEY'],
      aws_secret_access_key: ENV['S3_SECRET_KEY'],
      use_iam_profile:       true,
      region:                'us-west-1'
    }
    config.fog_directory  = ENV['S3_BUCKET']
    config.fog_public     = true
    config.fog_provider = 'fog/aws'
  end
end