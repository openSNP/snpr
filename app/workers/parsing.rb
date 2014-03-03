require 'open3' # requires Ruby >= 1.9.2

class Parsing
  include Sidekiq::Worker
  sidekiq_options :queue => :parse, :retry => 5, :unique => true

  def perform(genotype_id, temp_file)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/parsing_#{Rails.env}.log")

    genotype_id = genotype_id["genotype"]["id"].to_i if genotype_id.is_a?(Hash)

    # in test, database != env, in development, database == env
    log Rails.configuration.database_configuration[Rails.env]
    database = Rails.configuration.database_configuration[Rails.env]["database"]
    password = Rails.configuration.database_configuration[Rails.env]["password"]
    port =  Rails.configuration.database_configuration[Rails.env]["port"]
    if not port
      port = "5432"
    end
    username = Rails.configuration.database_configuration[Rails.env]["username"]
    # TODO: use rest of database_configuration so we can skip YAML parsing in goparser?
    command = "#{Rails.root}/app/workers/goParser -database=#{database} -genotype_id=#{genotype_id} -temp_file=#{temp_file} -root_path=#{Rails.root} -port=#{port} -username=#{username} -password=#{password}"
    log command
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
