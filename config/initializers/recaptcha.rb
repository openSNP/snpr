Recaptcha.configure do |config|
  config.public_key  = ENV.fetch('RECAPTCHA_PUBLIC_KEY')
  config.private_key = ENV.fetch('RECAPTCHA_PRIVATE_KEY')
end
