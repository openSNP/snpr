require 'open3' # requires Ruby >= 1.9.2

class Parsing
  include Sidekiq::Worker
  sidekiq_options :queue => :parse, :retry => 5, :unique => true

  def perform(genotype_id, temp_file)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/parsing_#{Rails.env}.log")

    genotype_id = genotype_id["genotype"]["id"].to_i if genotype_id.is_a?(Hash)

    # get database configuration for goparser
    database = Rails.configuration.database_configuration[Rails.env]["database"]
    password = Rails.configuration.database_configuration[Rails.env]["password"]
    port =  Rails.configuration.database_configuration[Rails.env]["port"]
    username = Rails.configuration.database_configuration[Rails.env]["username"]

    command = "#{Rails.root}/app/workers/goParser -database=#{database} -genotype_id=#{genotype_id} -temp_file=#{temp_file} -root_path=#{Rails.root} -port=#{port} -username=#{username} -password=#{password}"
    log "Parsing file #{temp_file}"
    stdout, stderr, status = Open3.capture3(command)
    log stderr
    log stdout
    log status
    if not status.success?
      genotype = Genotype.find(genotype_id)
      UserMailer.parsing_error(genotype.user_id).deliver
    end
    log "done with #{temp_file}"
    system("rm #{temp_file}")
  end

  def log msg
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
