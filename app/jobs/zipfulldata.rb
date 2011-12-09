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
      @time = Time.now
      
      # only create a new file if in the current minute none has been created yet
      
      if File.exists?(::Rails.root.to_s+"/public/data/zip/datadump."+@time.to_s.gsub(" ","_")+".zip") == false
        
        #create csv-head and writes to csv-filehandle
        
        @csv_head = "user_id;chrom_sex;date_of_birth"
        @csv_handle = File.new(::Rails.root.to_s+"/tmp/dump"+@time.to_s+".csv","w")
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
    
        # zip up the everything (csv + all genotypings) 
        
        Zip::ZipFile.open(::Rails.root.to_s+"/public/data/zip/datadump."+@time.to_s.gsub(" ","_")+".zip", Zip::ZipFile::CREATE) do |zipfile|
          zipfile.add("phenotypes_"+@time.to_s+".csv",::Rails.root.to_s+"/tmp/dump"+@time.to_s+".csv") 
          @genotyping_files.each do |gen_file|
            zipfile.add("user"+gen_file.user_id.to_s+"_file"+gen_file.id.to_s+"_yearofbirth"+gen_file.user.yearofbirth+"_sex"+gen_file.user.sex+"."+gen_file.filetype+".txt", ::Rails.root.to_s+"/public/data/"+ gen_file.fs_filename)
          end
        end
        
        File.delete(::Rails.root.to_s+"/tmp/dump"+@time.to_s+".csv")
        puts "created zip-file"
      end
      
      # make sure the file-permissions of the resulting zip-file are okay and sent mail
      system("chmod 777 "+::Rails.root.to_s+"/public/data/zip/datadump."+@time.to_s.gsub(" ","_")+".zip")
      UserMailer.genotyping_results(target_address,"/data/zip/datadump."+@time.to_s.gsub(" ","_")+".zip","JUST A TEST", "JUST A TEST").deliver
      puts "sent mail"
    else
      UserMailer.no_genotyping_results(target_address,"JUST AN EMPTY TEST","JUST AN EMPTY TEST").deliver
    end
  end
end