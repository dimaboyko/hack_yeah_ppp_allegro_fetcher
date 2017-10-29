REDIS_URI = 'redis://h:p4913fe0f0fce03aa992100b56ed3f49e03b26a7e0b2fb4e23010b1186a7ff3ab@ec2-34-250-82-211.eu-west-1.compute.amazonaws.com:29969'

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URI }
end

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URI }
end
