require 'resque'

class Preparsing
  @queue = :preparse

  def self.perform(genotype_id)
    genotype_id = genotype_id["genotype"]["id"].to_i if genotype_id.is_a?(Hash)
    @genotype = Genotype.find(genotype_id)
    filename = "#{Rails.root}/public/data/#{@genotype.fs_filename}"
    
    begin
      Zip::ZipFile.foreach(filename) do |entry|
        # if decodeme-file try to find the csv-file that includes all the data
        if @genotype.filetype == "decodeme"
          if entry.to_s.include?(".csv") == true
            puts "decodeme: found csv-file"
            Zip::ZipFile.open(filename) {
              |zipfile|
              zipfile.extract(entry,"#{Rails.root}/tmp/#{@genotype.fs_filename}.csv")
              zipfile.close()
              puts "extracted file"
            }
            system("mv #{Rails.root}/tmp/#{@genotype.fs_filename}.csv #{Rails.root}/public/data/#{@genotype.fs_filename}")
            puts "copied file"
          end
        
        elsif @genotype.filetype == "23andme"
          puts "23andme"
          if entry.to_s.include?("genome") == true
            puts "23andme: found genotyping-file"
            Zip::ZipFile.open(filename) {
              |zipfile|
              zipfile.extract(entry,"#{Rails.root}/tmp/#{@genotype.fs_filename}.tsv")
              zipfile.close()
              puts "extracted file"
            }
            system("mv #{Rails.root}/tmp/#{@genotype.fs_filename}.tsv #{Rails.root}/public/data/#{@genotype.fs_filename}")
            puts "copied file"
          end
            
        end
      end
      
    rescue
      puts "nothing to unzip, seems to be a text-file in the first place"
    end
    
    # now that they are unzipped, check if they're actually proper files
    
    file_is_ok = false
    fh = File.open("#{Rails.root}/public/data/#{@genotype.fs_filename}")
    l = fh.readline()
    # iterate as long as there's commenting going on
    while l.start_with?("#")
        l = fh.readline()
    end

    if @genotype.filetype == "23andme"
        # first non-comment line is of length 4 after split
        if l.split("\t").length == 4
            file_is_ok = true
        end
    elsif @genotype.filetype == "decodeme"
        # first line is of length 6
        if l.split(",").length == 6
            file_is_ok = true
        end
    elsif @genotype.filetype == "ftdna-illumina"
        # first line is of length 4
        if l.split(",").length == 4
            file_is_ok = true
        end
    end

    # not proper file!
    if not file_is_ok
        UserMailer.parsing_error(@genotype.user_id).deliver
        # should delete the uploaded file here, leaving that for now
        # might be better to keep the file for debugging
    else
        system("csplit -k -f #{@genotype.id}_tmpfile -n 4 #{filename} 20000 {2000}")
        system("mv #{@genotype.id}_tmpfile* tmp/")
        
        temp_files = Dir.glob("tmp/#{@genotype.id}_tmpfile*")
        temp_files.each do |single_temp_file|
        Resque.enqueue(Parsing, @genotype.id, single_temp_file)
        end
    end
  end
end
