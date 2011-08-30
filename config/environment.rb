# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Snpr::Application.initialize!

# ActionMailer logic so we can send out stuff
# following is example for gmail, change later
#config.action_mailer.delivery_method = :smtp
#config.action_mailer.smtp_settings = {
#  :address              => "smtp.gmail.com",
#  :port                 => 587,
#  :domain               => 'baci.lindsaar.net',
#  :user_name            => '<username>',
#  :password             => '<password>',
#  :authentication       => 'plain',
#  :enable_starttls_auto => true  }
