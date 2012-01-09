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
      @time = Time.now.utc.to_s.gsub(":","_")
      @time_str = @time.strftime("%Y%m%d%H%M")
      
      # only create a new file if in the current minute none has been created yet
      
      if File.exists?(::Rails.root.to_s+"/public/data/zip/opensnp_datadump."+@time_str+".zip") == false
        
        #create csv-head and writes to csv-filehandle
        
        @csv_head = "user_id;chrom_sex;date_of_birth"
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

        # make a README containing time of zip - this way, users can compare with page-status 
        # and see how old the data is
        @readme_handle = File.new(::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".txt","w")
        @phenotype_count = Phenotype.count
        @genotype_count = Genotype.count
        @readme_handle.puts("This archive was generated on "+@time.to_s+". It contains "+@phenotype_count.to_s+" phenotypes and "+@genotype_count.to_s+" genotypes.")
        @readme_handle.puts("Thanks for using openSNP!")
        @readme_handle.close
    
        # zip up the everything (csv + all genotypings + readme) 
        
        @zipname = "/data/zip/opensnp_datadump."+@time_str+".zip"
        Zip::ZipFile.open(::Rails.root.to_s+"/public/"+@zipname, Zip::ZipFile::CREATE) do |zipfile|
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
        end
        if FileLink.find_by_description("all genotypes and phenotypes archive") == nil
            @filelink = FileLink.new(:description => "all genotypes and phenotypes archive", :url => @zipname)
            @filelink.save
        else
            FileLink.find_by_description("all genotypes and phenotypes archive").update_attributes(:url => @zipname)
        end
        
        File.delete(::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".csv")
        File.delete(::Rails.root.to_s+"/tmp/dump"+@time_str.to_s+".txt")
        puts "created zip-file"
      end
      
      # make sure the file-permissions of the resulting zip-file are okay and sent mail
      system("chmod 777 "+::Rails.root.to_s+"/public/data/zip/opensnp_datadump."+@time_str+".zip")
      UserMailer.dump(target_address,"/data/zip/opensnp_datadump."+@time_str+".zip").deliver
      puts "sent mail"
    else
      UserMailer.no_dump(target_address).deliver
    end
  end
end
