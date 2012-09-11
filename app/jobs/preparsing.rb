require 'resque'

class Preparsing
  @queue = :preparse

  def self.perform(genotype_id)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/preparsing_#{Rails.env}.log")
    genotype_id = genotype_id["genotype"]["id"].to_i if genotype_id.is_a?(Hash)
    @genotype = Genotype.find(genotype_id)
    filename = "#{Rails.root}/public/data/#{@genotype.fs_filename}"
    
    log "Starting preparse"
    begin
      Zip::ZipFile.foreach(filename) do |entry|
        # if decodeme-file try to find the csv-file that includes all the data
        log "Checking for proper-filename"
        if @genotype.filetype == "decodeme"
          if entry.to_s.include?(".csv") == true
            log "decodeme: found csv-file"
            Zip::ZipFile.open(filename) {
              |zipfile|
              zipfile.extract(entry,"#{Rails.root}/tmp/#{@genotype.fs_filename}.csv")
              zipfile.close()
              log "extracted file"
            }
            system("mv #{Rails.root}/tmp/#{@genotype.fs_filename}.csv #{Rails.root}/public/data/#{@genotype.fs_filename}")
            log "copied file"
          end
        
        elsif @genotype.filetype == "23andme"
          log "23andme"
          if entry.to_s.include?("genome") == true
            log "23andme: found genotyping-file"
            Zip::ZipFile.open(filename) {
              |zipfile|
              zipfile.extract(entry,"#{Rails.root}/tmp/#{@genotype.fs_filename}.tsv")
              zipfile.close()
              log "extracted file"
            }
            system("mv #{Rails.root}/tmp/#{@genotype.fs_filename}.tsv #{Rails.root}/public/data/#{@genotype.fs_filename}")
            log "copied file"
          end

        elsif @genotype.filetype == "ftdna-illumina"
          log "ftdna"
          if entry.to_s.include?("csv")
            log "ftdna: found genotyping-file"
            Zip::ZipFile.open(filename) {
                |zipfile|
                zipfile.extract(entry,"#{Rails.root}/tmp/#{@genotype.fs_filename}.csv")
                zipfile.close()
                log "extracted file"
            }
            system("mv #{Rails.root}/tmp/#{@genotype.fs_filename}.csv #{Rails.root}/public/data/#{@genotype.fs_filename}")
            log "copied file"
          end
            
        end
      end
      
    rescue
      log "nothing to unzip, seems to be a text-file in the first place"
    end
    
    # now that they are unzipped, check if they're actually proper files
    
    file_is_ok = false
    fh = File.open("#{Rails.root}/public/data/#{@genotype.fs_filename}")
    l = fh.readline()
    # some files, for some reason, start with the UTF-BOM-marker
    l = l.sub("\uFEFF","")
    # iterate as long as there's commenting going on
    while l.start_with?("#")
        l = fh.readline()
        l = l.sub("\uFEFF","")
    end

    if @genotype.filetype == "23andme"
        # first non-comment line is of length 4 after split
        if l.split("\t").length == 4
            log "file is 23andme and is ok!"
            file_is_ok = true
        end
    elsif @genotype.filetype == "decodeme"
        # first line is of length 6
        if l.split(",").length == 6
            file_is_ok = true
            log "file is decodeme and is ok!"
        end
    elsif @genotype.filetype == "ftdna-illumina"
        # first line is of length 4
        if l.split(",").length == 4
            file_is_ok = true
            log "file is ftdna and is ok!"
        end
    elsif @genotype.filetype == "23andme-exome-vcf"
        #first line is ???
        if l.split("\t").length == 10
            file_is_ok = true
            log "file is 23andme-exome and is ok!"
        end
    end

    # not proper file!
    if not file_is_ok
        UserMailer.parsing_error(@genotype.user_id).deliver
        log "file is not ok, sending email"
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
  def self.log msg
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
