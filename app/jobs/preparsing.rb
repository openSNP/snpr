require 'resque'

class Preparsing
  @queue = :preparse

  def self.perform(genotyp)
    @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
    filename = "#{Rails.root}/public/data/#{@genotype.fs_filename}"
    
    system("csplit -k -f #{@genotype.id}_tmpfile -n 4 #{filename} 20000 {2000}")
    system("mv #{@genotype.id}_tmpfile* tmp/")
    
    temp_files = Dir.glob("tmp/#{@genotype.id}_tmpfile*")
    temp_files.each do |single_temp_file|
      Resque.enqueue(Parsing,@genotype,single_temp_file)
    end
  end
end