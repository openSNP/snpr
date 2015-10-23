

class FitbitEndSubscription
   include Sidekiq::Worker
   sidekiq_options :queue => :fitbit, :retry => 5, :unique => true

   def perform(fitbit_profile_id)
     @fitbit_profile = FitbitProfile.find_by_id(fitbit_profile_id)
     @client = Fitgem::Client.new(consumer_key: ENV.fetch('FITBIT_CONSUMER_KEY'),
                                  consumer_secret: ENV.fetch('FITBIT_CONSUMER_SECRET'))
     @client.reconnect(@fitbit_profile.access_token, @fitbit_profile.access_secret)
     @client.remove_subscription({:type => :all, :subscriber_id => "general", :subscription_id => @fitbit_profile.id})
     @fitbit_profile.destroy()
   end
 end
