require 'resque'

class Zipgenotypingfiles
  @queue = :zipgenotyping

  def self.perform(phenotype_id,variation,target_address)
    @user_phenotypes = UserPhenotype.find_all_by_phenotype_id_and_variation(phenotype_id,variation)
    @genotyping_files = []
    @user_phenotypes.each do |up|
      @user = User.find_by_id(up.user_id)
      print @user
      if @user.genotypes[0] != nil
        @genotyping_files << @user.genotypes[0].fs_filename
      end
    end

    if @genotyping_files != []
      @time = Time.now
      if File.exists?(::Rails.root.to_s+"/public/data/zip/"+phenotype_id.to_s+"."+@time.to_s.gsub(" ","_")+".zip") == false
        Zip::ZipFile.open(::Rails.root.to_s+"/public/data/zip/"+phenotype_id.to_s+"."+@time.to_s.gsub(" ","_")+".zip", Zip::ZipFile::CREATE) do |zipfile| 
          @genotyping_files.each do |gen_file|
            zipfile.add(gen_file, "#{RAILS_ROOT}/public/data/"+ gen_file)
          end
        end
      end
      UserMailer.genotyping_results(target_address,"/data/zip/"+phenotype_id.to_s+"."+@time.to_s.gsub(" ","_")+".zip",Phenotype.find_by_id(phenotype_id).characteristic,variation).deliver
    else
      UserMailer.no_genotyping_results(target_address,Phenotype.find_by_id(phenotype_id).characteristic,variation).deliver
    end
  end

end