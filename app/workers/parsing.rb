require 'open3' # requires Ruby >= 1.9.2

class Parsing
  include Sidekiq::Worker
  sidekiq_options :queue => :parse, :retry => 5, :unique => true

  def perform(genotype_id, temp_file)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/parsing_#{Rails.env}.log")
    genotype_id = genotype_id["genotype"]["id"].to_i if genotype_id.is_a?(Hash)
    command = "./goworker #{genotype_id} #{temp_file}"
    log "Parsing file #{temp_file}"
    stdout,stderr,status = Open3.capture3(command)
    log stdout
    log stderr
    log status
    #UserMailer.parsing_error(@genotype.user_id).deliver
    log "done with #{temp_file}"
    #system("rm #{temp_file}")
  end

  def log msg
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
