# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Snpr::Application.initialize!

# ActionMailer logic so we can send out stuff
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :address => "servername.domain.com",
   :port => 25,
   :domain => "domain.com",
   :authentication => :login,
   :user_name => "login",
   :password => "password"
 }

