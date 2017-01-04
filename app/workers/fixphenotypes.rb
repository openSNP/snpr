# frozen_string_literal: true
class Fixphenotypes
  include Sidekiq::Worker
  sidekiq_options :queue => :fixphenotypes, :retry => 5, :unique => true

  def perform()
    Phenotype.find_each do |p|
      # is it empty?
      unless p.user_phenotypes.exists?
        # delete!
        logger.info("Deleting phenotype '#{p.characteristic}'")
        Phenotype.destroy(p)
      end
    end
  end
end
