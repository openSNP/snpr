require 'resque'

class Zipfulldata
  @queue = :zipfulldata

  def self.perform(target_address)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/zipfulldata_#{Rails.env}.log")
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
        log "created csv-file"
        
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
          log "Saved fibit-date for "
        end

        # picture phenotype zipping comes here
        
        # make a CSV describing all of them - which filename is for which user's phenotype
        @csv_head = "user_id;date_of_birth;chrom_sex"
        @csv_handle = File.new(::Rails.root.to_s+"/tmp/picture_dump"+@time_str.to_s+".csv","w")

        log "Writing picture-CSV to #{::Rails.root.to_s+"/tmp/picture_dump"+@time_str.to_s+".csv"}"

        PicturePhenotype.find_each do |p|
          @csv_head = @csv_head + ";" + p.characteristic.gsub(";",",")
        end
        @csv_handle.puts(@csv_head)
    
        # create lines in csv-file for each user who has uploaded his data
        
        @list_of_pics = [] # need this for the zip-file-later

        User.all.each do |u|
          @user_line = u.id.to_s + ";" + u.yearofbirth + ";" + u.sex
          log "Looking at user #{u.id}"
          PicturePhenotype.all.each do |up|

            # copy the picture with name to +user_id+_+pic_phenotype_id+.png
            log "Looking for this picture #{up.id}"
            @picture = UserPicturePhenotype.find_by_user_id_and_picture_phenotype_id(u.id,up.id)
            # does this user have this pic?
            if @picture != nil
              @file_name = @picture.phenotype_picture.path
              @basename = @file_name.split("/")[-1]
              @filetype = @basename.split(".")[-1]
              log "FOUND file #{@file_name}, basename is #{@basename}"

              @list_of_pics << @picture
              @user_line = @user_line + ";" + @picture.id.to_s + "." +  @filetype
            else 
              @user_line = @user_line + ";" + "-"
            end
          end
          log "Putting a line into CSV"
          @csv_handle.puts(@user_line)
        end
        
        @csv_handle.close
        log "created picture handle csv-file"

        # now create zipfile of pictures
        @pic_zipname = "/data/zip/opensnp_picturedump."+@time_str+".zip"
        Zip::ZipFile.open(::Rails.root.to_s + "/public/" + @pic_zipname, Zip::ZipFile::CREATE) do |z|
          @list_of_pics.each do |tmp|
            begin
              @file_name = tmp.phenotype_picture.path
              @basename = @file_name.split("/")[-1]
              @filetype = @basename.split(".")[-1]
              log "Adding file to zip named #{tmp.id.to_s + "." + @filetype}"
              z.add(tmp.id.to_s+"."+@filetype, @file_name)
              log "Added #{tmp.id.to_s + "." + @filetype}"
            rescue
              log "missing file"
            end
          end
        end

        log "created picture zip file"
        
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
        log "created zip-file"
      end
      
      # make sure the file-permissions of the resulting zip-file are okay and send mail
      system("chmod 777 "+::Rails.root.to_s+"/public/data/zip/opensnp_datadump."+@time_str+".zip")
      UserMailer.dump(target_address,"/data/zip/opensnp_datadump."+@time_str+".zip").deliver
      log "sent mail"
    else
      UserMailer.no_dump(target_address).deliver
    end
  end

  def self.log msg
      Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
