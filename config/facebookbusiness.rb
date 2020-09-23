FacebookAds.configure do |config|
  config.api_version = 'v6.0'
  config.app_secret = ENV['FACEBOOK_APP_SECRET']
  # Log HTTP request & response to logger
  config.log_api_bodies = true
  # Logger for debugger
  config.logger = ::Logger.new(STDOUT).tap { |d| d.level = Logger::DEBUG }
end
