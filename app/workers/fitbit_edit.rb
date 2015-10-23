

class FitbitEdit
   include Sidekiq::Worker
   sidekiq_options :queue => :fitbit, :retry => 5, :unique => true

   def perform(fitbit_profile_id)
     @fitbit_profile = FitbitProfile.find_by_id(fitbit_profile_id)
     @client = Fitgem::Client.new(consumer_key: ENV.fetch('FITBIT_CONSUMER_KEY'),
                                  consumer_secret: ENV.fetch('FITBIT_CONSUMER_SECRET'))
     @client.reconnect(@fitbit_profile.access_token, @fitbit_profile.access_secret)
     @return_value = @client.create_subscription({:type => :all, :subscription_id => @fitbit_profile.id})
     puts "subscription returned: "+ @return_value[0]
     if @return_value[0] == "409"
       @client.remove_subscription({:type => :all, :subscriber_id => "general",:subscription_id => @return_value[1]["subscriptionId"]})
       @client.create_subscription({:type => :all, :subscription_id => @fitbit_profile.id})
     end
     
     if @fitbit_profile.body == false
       @entries = FitbitBody.where(fitbit_profile_id: @fitbit_profile.id)
       @entries.each do |e|
         e.delete
       end
     else
       # grab all data so far
       @bmi_array = @client.data_by_time_range("/body/bmi",{:base_date => Date.today.to_s,:period => :max})["body-bmi"]
       puts @bmi_array
       @bmi_array.each do |bmi|
         @body = FitbitBody.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,bmi["dateTime"])
         @body.bmi = bmi["value"]
         @body.save
       end
       @weight_array = @client.data_by_time_range("/body/weight",{:base_date => Date.today.to_s,:period => :max})["body-weight"]
       @weight_array.each do |weight|
         @body = FitbitBody.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,weight["dateTime"])
         @body.weight = weight["value"]
         @body.save
       end
     end
     
     # check for sleep data & subscriptions
     if @fitbit_profile.sleep == false
       @entries = FitbitSleep.where(fitbit_profile_id: @fitbit_profile.id)
       @entries.each do |e|
         e.delete
       end
     else
       # grab data
       @minutes_asleep_array = @client.data_by_time_range("/sleep/minutesAsleep",{:base_date => Date.today.to_s,:period => :max})["sleep-minutesAsleep"]
       @minutes_asleep_array.each do |m_asleep|
         @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,m_asleep["dateTime"])
         @sleep.minutes_asleep = m_asleep["value"]
         @sleep.save
       end
       @awakenings_array = @client.data_by_time_range("/sleep/awakeningsCount",{:base_date => Date.today.to_s,:period => :max})["sleep-awakeningsCount"]
       @awakenings_array.each do |awake|
         @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,awake["dateTime"])
         @sleep.number_awakenings = awake["value"]
         @sleep.save
       end
       @minutes_awake_array = @client.data_by_time_range("/sleep/minutesAwake",{:base_date => Date.today.to_s,:period => :max})["sleep-minutesAwake"]
       @minutes_awake_array.each do |m_awake|
         @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,m_awake["dateTime"])
         @sleep.minutes_awake = m_awake["value"]
         @sleep.save
       end
       @minutes_to_sleep_array = @client.data_by_time_range("/sleep/minutesToFallAsleep",{:base_date => Date.today.to_s,:period => :max})["sleep-minutesToFallAsleep"]
       @minutes_to_sleep_array.each do |m|
         @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,m["dateTime"])
         @sleep.minutes_to_sleep = m["value"]
         @sleep.save
       end
     end
     
     # check for activities data
     if @fitbit_profile.activities == false
       @entries = FitbitActivity.where(fitbit_profile_id: @fitbit_profile.id)
       @entries.each do |e|
         e.delete
       end
     else
       @steps_array = @client.data_by_time_range("/activities/log/steps",{:base_date => Date.today.to_s,:period => :max})["activities-log-steps"]
       puts "ACTIVITIES!!!"
       puts @steps_array
       @steps_array.each do |s|
         @activity = FitbitActivity.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,s["dateTime"])
         @activity.steps = s["value"]
         @activity.save
       end
       @floors_array = @client.data_by_time_range("/activities/log/floors",{:base_date => Date.today.to_s,:period => :max})["activities-log-floors"]
       @floors_array.each do |f|
         @activity = FitbitActivity.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,f["dateTime"])
         @activity.floors = f["value"]
         @activity.save
       end
       # grab data
     end
   end
end
