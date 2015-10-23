

class FitbitNotification
   include Sidekiq::Worker
   sidekiq_options :queue => :fitbit, :retry => 5, :unique => true

   def perform(notification)
     puts notification
     notification.each do |n|
       @fitbit_profile = FitbitProfile.find_by_id(n["subscriptionId"])
       if @fitbit_profile != nil
         @client = Fitgem::Client.new(consumer_key: ENV.fetch('FITBIT_CONSUMER_KEY'),
                                      consumer_secret: ENV.fetch('FITBIT_CONSUMER_SECRET'))
         @client.reconnect(@fitbit_profile.access_token, @fitbit_profile.access_secret)
         puts n
         puts n["collectionType"]
         if n["collectionType"] == "activities" and @fitbit_profile.activities == true
           @activity = FitbitActivity.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,n["date"])
           @steps = @client.data_by_time_range("/activities/log/steps",{:base_date => n["date"],:period => "1d"})["activities-log-steps"][0]["value"]
           @floors = @client.data_by_time_range("/activities/log/floors",{:base_date => n["date"],:period => "1d"})["activities-log-floors"][0]["value"]
           puts @steps
           puts @floors
           @activity.steps = @steps
           @activity.floors = @floors
           @activity.save
         elsif n["collectionType"] == "sleep"
           @sleep = FitbitSleep.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,n["date"])
           @sleep.minutes_asleep = @client.data_by_time_range("/sleep/minutesAsleep",{:base_date => n["date"],:period => "1d"})["sleep-minutesAsleep"][0]["value"]
           @sleep.number_awakenings = @client.data_by_time_range("/sleep/awakeningsCount",{:base_date => n["date"],:period => "1d"})["sleep-awakeningsCount"][0]["value"]
           @sleep.minutes_awake = @client.data_by_time_range("/sleep/minutesAwake",{:base_date => n["date"],:period => "1d"})["sleep-minutesAwake"][0]["value"]
           @sleep.minutes_to_sleep = @client.data_by_time_range("/sleep/minutesToFallAsleep",{:base_date => n["date"],:period => "1d"})["sleep-minutesToFallAsleep"][0]["value"]
           @sleep.save
         elsif n["collectionType"] == "body"
           @body = FitbitBody.find_or_create_by_fitbit_profile_id_and_date_logged(@fitbit_profile.id,n["date"])
           @body.bmi = @client.data_by_time_range("/body/bmi",{:base_date => n["date"],:period => "1d"})["body-bmi"][0]["value"]
           @body.weight = @client.data_by_time_range("/body/weight",{:base_date => n["date"],:period => "1d"})["body-weight"][0]["value"]
           @body.save
         end
       end
     end
   end
end
