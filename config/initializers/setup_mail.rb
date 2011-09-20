username = File.open(::Rails.root.to_s+"/mail_username.txt").readline.rstrip
password = File.open(::Rails.root.to_s+"/mail_password.txt").readline.rstrip

ActionMailer::Base.smtp_settings = {
  :address              => "smtp.googlemail.com",
  :port                 => 587,
  :domain               => 'googlemail.com',
  :user_name            => username,
  :password             => password,
  :authentication       => 'plain',
  :enable_starttls_auto => true
    }

ActionMailer::Base.default_url_options[:host] = "localhost:3000" 