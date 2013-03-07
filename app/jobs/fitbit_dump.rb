require 'resque'

class FitbitDump
   include Sidekiq::Worker
   @queue = :fitbitdump

   def perform(target_address,fitbit_profile_id)
     fp = FitbitProfile.find_by_id(fitbit_profile_id)
       # open handle
       
       @time = Time.now.utc
       @time_str = @time.strftime("%Y%m%d%H%M")
       @time = @time.to_s.gsub(":","_")
       
       @fitbit_handle = File.new(::Rails.root.to_s+"/public/data/fitbit/user"+fp.user.id.to_s+"_fitbit_data_"+@time_str.to_s+".csv","w")
       @fitbit_handle.puts("date;steps;floors;weight;bmi;minutes asleep;minutes awake; times awaken; minutes until fell asleep")
       
       # get all dates which have to be included in the csv
       @time_array = []
       fp.fitbit_bodies.each do |fb|
         @time_array << fb.date_logged
       end
       fp.fitbit_sleeps.each do |fs|
         @time_array << fs.date_logged
       end
       fp.fitbit_activities.each do |fa|
         @time_array << fa.date_logged
       end
       
       @time_array = @time_array.uniq.sort
       
       @time_array.each do |d|
         @line = d.to_s + ";"
         @activity = fp.fitbit_activities.find_by_date_logged(d)
         if @activity == nil
           @line = @line + "-;-;"
         else
           @line = @line + @activity.steps.to_s + ";" + @activity.floors.to_s+ ";"
         end
         
         @body = fp.fitbit_bodies.find_by_date_logged(d)
         if @body == nil
           @line = @line + "-;-;"
         else
           @line = @line + @body.weight.to_s + ";" + @body.bmi.to_s + ";"
         end
         
         @sleep = fp.fitbit_sleeps.find_by_date_logged(d)
         if @sleep == nil
           @line = @line + "-;-;-;-;"
         else
           @line = @line + @sleep.minutes_asleep.to_s+";"+@sleep.minutes_awake.to_s+";"+@sleep.number_awakenings.to_s+";"+@sleep.minutes_to_sleep.to_s+";"
         end
         @fitbit_handle.puts(@line)
       end
       @fitbit_handle.close
       puts "Saved fibit-date for "
       system("chmod 777 "+::Rails.root.to_s+"/public/data/fitbit/user"+fp.user.id.to_s+"_fitbit_data_"+@time_str.to_s+".csv")
       UserMailer.fitbit_dump(target_address,"/data/fitbit/user"+fp.user.id.to_s+"_fitbit_data_"+@time_str.to_s+".csv").deliver
     end
end
