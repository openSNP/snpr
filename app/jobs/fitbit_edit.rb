require 'resque'

class FitbitEdit
   @queue = :fitbitedit

   def self.perform(fitbit_profile_id)
     @fitbit_profile = FitbitProfile.find_by_id(fitbit_profile_id)
     @client = Fitgem::Client.new(:consumer_key => APP_CONFIG[:fitbit_consumer_key], :consumer_secret => APP_CONFIG[:fitbit_consumer_secret])
     @client.reconnect(@fitbit_profile.access_token, @fitbit_profile.access_secret)
     @client.create_subscription({:type => :all, :subscription_id => @fitbit_profile.id})
     
     # check for body data & subscriptions
     ###############################################
     ##             TODO!!!111                    ##
     ## SET UP SUBSCRIPTION API ON THIS POINT!!!1 ##
     ###############################################
     
     if @fitbit_profile.body == false
       @entries = FitbitBody.find_all_by_fitbit_profile_id(@fitbit_profile.id)
       @entries.each do |e|
         e.delete
       end
     else
       # grab all data so far
       @bmi_array = @client.data_by_time_range("/body/bmi",{:base_date => Date.today.to_s,:period => :max})["body-bmi"]
       @bmi_array.each do |bmi|
         @body = FitbitBody.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,bmi["dateTime"])
         @body.bmi = bmi["value"]
         @body.save
         puts "saved bmi"
       end
       @weight_array = @client.data_by_time_range("/body/weight",{:base_date => Date.today.to_s,:period => :max})["body-weight"]
       @weight_array.each do |weight|
         @body = FitbitBody.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,weight["dateTime"])
         @body.weight = weight["value"]
         @body.save
         puts "saved weight"
       end
     end
     
     # check for sleep data & subscriptions
     if @fitbit_profile.sleep == false
       @entries = FitbitSleep.find_all_by_fitbit_profile_id(@fitbit_profile.id)
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
         puts "saved minutes asleep"
       end
       @awakenings_array = @client.data_by_time_range("/sleep/awakeningsCount",{:base_date => Date.today.to_s,:period => :max})["sleep-awakeningsCount"]
       @awakenings_array.each do |awake|
         @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,awake["dateTime"])
         @sleep.number_awakenings = awake["value"]
         @sleep.save
         puts "saved times awake"
       end
       @minutes_awake_array = @client.data_by_time_range("/sleep/minutesAwake",{:base_date => Date.today.to_s,:period => :max})["sleep-minutesAwake"]
       @minutes_awake_array.each do |m_awake|
         @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,m_awake["dateTime"])
         @sleep.minutes_awake = m_awake["value"]
         @sleep.save
         puts "saved minutes awake"
       end
       @minutes_to_sleep_array = @client.data_by_time_range("/sleep/minutesToFallAsleep",{:base_date => Date.today.to_s,:period => :max})["sleep-minutesToFallAsleep"]
       @minutes_to_sleep_array.each do |m|
         @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,m["dateTime"])
         @sleep.minutes_to_sleep = m["value"]
         @sleep.save
         puts "saved minutes to sleep"
       end
     end
     
     # check for activities data
     if @fitbit_profile.activities == false
       @entries = FitbitActivity.find_all_by_fitbit_profile_id(@fitbit_profile.id)
       @entries.each do |e|
         e.delete
       end
     else
       @steps_array = @client.data_by_time_range("/activities/log/steps",{:base_date => Date.today.to_s,:period => :max})["activities-log-steps"]
       @steps_array.each do |s|
         @activity = FitbitActivity.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,s["dateTime"])
         @activity.steps = s["value"]
         @activity.save
         puts "saved steps"
       end
       @floors_array = @client.data_by_time_range("/activities/log/floors",{:base_date => Date.today.to_s,:period => :max})["activities-log-floors"]
       @floors_array.each do |f|
         @activity = FitbitActivity.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,f["dateTime"])
         @activity.floors = f["value"]
         @activity.save
         puts "saved floors"
       end
       # grab data
     end
   end
end
