require 'resque'

class Zipfulldata
  @queue = :zipfulldata

  def self.perform(target_address)
    @user_phenotypes = UserPhenotype.find_all_by_phenotype_id_and_variation(phenotype_id,variation)
    @genotyping_files = []
    @users = []
    
    Genotype.find_each do |g|
      @genotyping_files << g
      @users << User.find(g.user_id)
    end
    
    @csv_head = "user_id;chrom_sex;date_of_birth"
    @phenotype_id_array = []
    
    Phenotype.find_each do |p|
      @phenotype_id_array << p.id
      @csv_head = @csv_head + p.characteristic.gsub(";",",")
    end
    
    #ruby-1.9.2-p290 :011 > User.find_each do |u|
    #ruby-1.9.2-p290 :012 >     phenotype_id_array.each do |parray|
    #ruby-1.9.2-p290 :013 >       puts UserPhenotype.find_by_user_id_and_phenotype_id(u.id,parray)
    #ruby-1.9.2-p290 :014?>     end
    #ruby-1.9.2-p290 :015?>   puts "next user"
    #ruby-1.9.2-p290 :016?>   end
    
    @user_phenotypes.each do |up|
      @user = User.find_by_id(up.user_id)
      print @user
      if @user.genotypes[0] != nil
        @genotyping_files << @user.genotypes[0]
      end
    end

    if @genotyping_files != []
      @time = Time.now
      if File.exists?(::Rails.root.to_s+"/public/data/zip/"+phenotype_id.to_s+"."+@time.to_s.gsub(" ","_")+".zip") == false
        Zip::ZipFile.open(::Rails.root.to_s+"/public/data/zip/"+phenotype_id.to_s+"."+@time.to_s.gsub(" ","_")+".zip", Zip::ZipFile::CREATE) do |zipfile| 
          @genotyping_files.each do |gen_file|
            zipfile.add("user"+gen_file.user_id.to_s+"_file"+gen_file.id.to_s+"_yearofbirth"+gen_file.user.yearofbirth+"_sex"+gen_file.user.sex+"."+gen_file.filetype+".txt", ::Rails.root.to_s+"/public/data/"+ gen_file.fs_filename)
          end
        end
      end
      system("chmod 777 "+::Rails.root.to_s+"/public/data/zip/"+phenotype_id.to_s+"."+@time.to_s.gsub(" ","_")+".zip")
      UserMailer.genotyping_results(target_address,"/data/zip/"+phenotype_id.to_s+"."+@time.to_s.gsub(" ","_")+".zip",Phenotype.find_by_id(phenotype_id).characteristic,variation).deliver
    else
      UserMailer.no_genotyping_results(target_address,Phenotype.find_by_id(phenotype_id).characteristic,variation).deliver
    end
  end
end