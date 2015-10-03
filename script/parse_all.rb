logger = Logger.new('log/parse_all.log')
logger.formatter = Logger::Formatter.new

Genotype.order('id desc').pluck(:id).each do |genotype_id|
  logger.info "Parsing Genotype(#{genotype_id}) ..."
  begin
    Preparsing.new.perform(genotype_id)
    logger.info "Successfully parsed Genotype(#{genotype_id}) ..."
  rescue => e
    logger.error("Genotype(#{genotype_id}): #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
  end
end
