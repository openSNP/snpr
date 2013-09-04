

class Zipgenotypingfiles
  include Sidekiq::Worker
  sidekiq_options :queue => :zipgenotyping, :retry => 5, :unique => true

  def perform(phenotype_id, variation, target_address)
    @user_phenotypes = Sunspot.search(UserPhenotype) do
      with :phenotype_id, phenotype_id
      fulltext variation
    end.results
    @genotyping_files = []
    @user_phenotypes.each do |up|
      @user = User.find_by_id(up.user_id)
      print @user
      if @user.genotypes.length != 0
        @user.genotypes.each do |g|
          @genotyping_files << g
        end
      end
    end

    if @genotyping_files != []
      @time = Time.now.to_s.gsub(":","_")
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
