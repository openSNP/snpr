

class FitbitInit
   include Sidekiq::Worker
   sidekiq_options :queue => :fitbit

   def perform(fitbit_profile_id)
     @client = Fitgem::Client.new(:consumer_key => APP_CONFIG[:fitbit_consumer_key], :consumer_secret => APP_CONFIG[:fitbit_consumer_secret])
     fitbit_profile = FitbitProfile.find_by_id(fitbit_profile_id)
     @client.reconnect(fitbit_profile.access_token, fitbit_profile.access_secret)
     fitbit_id = @client.user_info["user"]["encodedId"]
     puts fitbit_id
     fitbit_profile.fitbit_user_id = fitbit_id
     fitbit_profile.save
     puts fitbit_profile.fitbit_user_id
   end
end
