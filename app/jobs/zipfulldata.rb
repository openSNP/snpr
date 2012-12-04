require 'resque'

class Zipfulldata
  @queue = :zipfulldata

  def self.perform(target_address)
    @genotyping_files = []
    @users = []

    Genotype.find_each do |g|
      @genotyping_files << g
      @users << User.find(g.user_id)
    end
    
    # only try to create csv & zip-file if there is data at all. 
    
    if @genotyping_files != []
      @time = Time.now.utc
      @time_str = @time.strftime("%Y%m%d%H%M")
      @time = @time.to_s.gsub(":","_")
      
      # only create a new file if in the current minute none has been created yet
      
      if File.exists?(::Rails.root.to_s+"/public/data/zip/opensnp_datadump."+@time_str+".zip") == false
        
        #create csv-head and writes to csv-filehandle
        
        @csv_head = "user_id;date_of_birth;chrom_sex"
        @csv_handle = File.new(::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".csv","w")
        @phenotype_id_array = []
    
        Phenotype.find_each do |p|
          @phenotype_id_array << p.id
          @csv_head = @csv_head + ";" + p.characteristic.gsub(";",",")
        end
        @csv_handle.puts(@csv_head)
    
        # create lines in csv-file for each user who has uploaded his data
        
        @users.each do |u|
          @user_line = u.id.to_s + ";" + u.yearofbirth + ";" + u.sex
          @phenotype_id_array.each do |pid|
            if UserPhenotype.find_by_user_id_and_phenotype_id(u.id,pid) != nil
              @user_line = @user_line + ";" + UserPhenotype.find_by_user_id_and_phenotype_id(u.id,pid).variation.gsub(";",",")
            else 
              @user_line = @user_line + ";" + "-"
            end          
          end
          @csv_handle.puts(@user_line)
        end
        
        @csv_handle.close
        puts "created csv-file"
        
        # Create a file of fitbit-data for each user with fitbit-data
        
        @fitbit_profiles = FitbitProfile.find(:all)
        @fitbit_profiles.each do |fp|
          # open handle
          @fitbit_handle = File.new(::Rails.root.to_s+"/tmp/dump_user"+fp.user.id.to_s+"_fitbit_data_"+@time_str.to_s+".csv","w")
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
            @line = d + ";"
            @activity = fp.fitbit_activities.find_by_date_logged(d)
            if @activity == nil
              @line = @line + "-;-;"
            else
              @line = @line + @activity.steps + ";" + @activity.floors+ ";"
            end
            
            @body = fp.fitbit_bodies.find_by_date_logged(d)
            if @body == nil
              @line = @line + "-;-;"
            else
              @line = @line + @body.weight + ";" + @body.bmi + ";"
            end
            
            @sleep = fp.fitbit_sleeps.find_by_date_logged(d)
            if @sleep == nil
              @line = @line + "-;-;-;-;"
            else
              @line = @line + @sleep.minutes_asleep+";"+@sleep.minutes_awake+";"+@sleep.number_awakenings+";"+@sleep.minutes_to_sleep+";"
            end
            @fitbit_handle.puts(@line)
          end
          @fitbit_handle.close
          puts "Saved fibit-date for "
        end

        # picture phenotype zipping comes here
        
        # make a CSV describing all of them - which filename is for which user's phenotype
        @csv_head = "user_id;date_of_birth;chrom_sex"
        @csv_handle = File.new(::Rails.root.to_s+"/tmp/picture_dump"+@time_str.to_s+".csv","w")
        @pic_phenotype_id_array = []
    
        PicturePhenotype.find_each do |p|
          @pic_phenotype_id_array << p.id
          @csv_head = @csv_head + ";" + p.characteristic.gsub(";",",")
        end
        @csv_handle.puts(@csv_head)
    
        # create lines in csv-file for each user who has uploaded his data
        
        @list_of_temporary_pics = [] # need this for the zip-file-later

        @users.each do |u|
          @user_line = u.id.to_s + ";" + u.yearofbirth + ";" + u.sex
          @pic_phenotype_id_array.each do |pid|

            # copy the picture with name to +user_id+_+pic_phenotype_id+.png
            @file_name = u.id.to_s + "_" + pid.to_s + ".png"

            @picture = UserPicturePhenotype.find_by_user_id_and_picture_phenotype_id(u.id,pid)
            puts "FOUND THIS"
            puts @picture
            if @picture != nil
              @list_of_temporary_pics << "/tmp/pics/" + @file_name
              system("cp " + ::Rails.root.to_s + "/public/system/phenotype_pictures/" + @picture.picture_phenotype_id.to_s + "/original/" + @picture.phenotype_picture_file_name.to_s + " " + ::Rails.root.to_s + "/tmp/pics/" + @file_name)
              @user_line = @user_line + ";" + @file_name
            else 
              @user_line = @user_line + ";" + "-"
            end
          end
          @csv_handle.puts(@user_line)
        end
        
        @csv_handle.close
        puts "created picture handle csv-file"

        # now create zipfile of pictures
        @pic_zipname = "/data/zip/opensnp_picturedump."+@time_str+".zip"
        Zip::ZipFile.open(::Rails.root.to_s + "/public/" + @pic_zipname, Zip::ZipFile::CREATE) do |z|
          @list_of_temporary_pics.each do |tmp|
              basename = tmp.split("/")[-1]
              z.add(basename, ::Rails.root.to_s + "/" + tmp)
          end
        end

        puts "created picture zip file"
        @list_of_temporary_pics.each do |tmp|
            system("rm " + ::Rails.root.to_s + "/" + tmp) 
        end
        
        puts "deleted temporary pics"

       
        # make a README containing time of zip - this way, users can compare with page-status 
        # and see how old the data is
        @readme_handle = File.new(::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".txt","w")
        @phenotype_count = Phenotype.count
        @genotype_count = Genotype.count
        @picture_count = PicturePhenotype.count
        @readme_handle.puts("This archive was generated on "+@time.to_s+" UTC. It contains "+@phenotype_count.to_s+" phenotypes, "+@genotype_count.to_s+" genotypes and " + @picture_count.to_s + " picture phenotypes.")
        @readme_handle.puts("Thanks for using openSNP!")
        @readme_handle.close
    
        # zip up everything (csv + all genotypings + pics-zip + pics-csv + readme) 
        
        @zipname = "/data/zip/opensnp_datadump."+@time_str+".zip"
        Zip::ZipFile.open(::Rails.root.to_s+"/public/"+@zipname, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.add("picture_phenotypes_" + @time_str.to_s + ".csv", ::Rails.root.to_s+"/tmp/picture_dump"+@time_str.to_s+".csv")
          zipfile.add("picture_phenotypes_" + @time_str.to_s + "_all_pics.zip", ::Rails.root.to_s + "/public/" + @pic_zipname)
          zipfile.add("phenotypes_"+@time_str.to_s+".csv",::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".csv") 
          zipfile.add("readme.txt",::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".txt")
          @genotyping_files.each do |gen_file|
            @yob = gen_file.user.yearofbirth
            @sex = gen_file.user.sex
            if @yob == "rather not say"
                @yob = "unknown"
            end
            if @sex == "rather not say"
                @sex = "unknown"
            end
            zipfile.add("user"+gen_file.user_id.to_s+"_file"+gen_file.id.to_s+"_yearofbirth_"+@yob+"_sex_"+@sex+"."+gen_file.filetype+".txt", ::Rails.root.to_s+"/public/data/"+ gen_file.fs_filename)
          end
          
          @fitbit_profiles.each do |fp|
            zipfile.add("user"+fp.user.id.to_s+"_fitbit_data_"+@time_str.to_s+".csv",::Rails.root.to_s+"/tmp/dump_user"+fp.user.id.to_s+"_fitbit_data_"+@time_str.to_s+".csv")
          end
          
        end
        if FileLink.find_by_description("all genotypes and phenotypes archive") == nil
            @filelink = FileLink.new(:description => "all genotypes and phenotypes archive", :url => @zipname)
            @filelink.save
        else
            FileLink.find_by_description("all genotypes and phenotypes archive").update_attributes(:url => @zipname)
        end
        
        File.delete(::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".csv")
        File.delete(::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".txt")
        @fitbit_profiles.each do |fp|
          File.delete(::Rails.root.to_s+"/tmp/dump_user"+fp.user.id.to_s+"_fitbit_data_"+@time_str.to_s+".csv")
        end
        puts "created zip-file"
      end
      
      # make sure the file-permissions of the resulting zip-file are okay and send mail
      system("chmod 777 "+::Rails.root.to_s+"/public/data/zip/opensnp_datadump."+@time_str+".zip")
      UserMailer.dump(target_address,"/data/zip/opensnp_datadump."+@time_str+".zip").deliver
      puts "sent mail"
    else
      UserMailer.no_dump(target_address).deliver
    end
  end
end
