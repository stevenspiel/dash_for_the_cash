OmniAuth.config.logger = Rails.logger

google_secret = Rails.env.production? ? ENV["GOOGLE_CLIENT_SECRET_PRODUCTION"] : ENV["GOOGLE_CLIENT_SECRET"]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], google_secret
end