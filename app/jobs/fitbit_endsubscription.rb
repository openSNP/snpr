require 'resque'

class FitbitEndSubscription
   @queue = :fitbitendsubscription

   def perform(fitbit_profile_id)
     @fitbit_profile = FitbitProfile.find_by_id(fitbit_profile_id)
     @client = Fitgem::Client.new(:consumer_key => APP_CONFIG[:fitbit_consumer_key], :consumer_secret => APP_CONFIG[:fitbit_consumer_secret])
     @client.reconnect(@fitbit_profile.access_token, @fitbit_profile.access_secret)
     @client.remove_subscription({:type => :all, :subscriber_id => "general", :subscription_id => @fitbit_profile.id})
     @fitbit_profile.destroy()
   end
 end