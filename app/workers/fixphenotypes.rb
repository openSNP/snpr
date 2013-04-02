

class Fixphenotypes
  include Sidekiq::Worker
  sidekiq_options :queue => :fixphenotypes, :retry => 5

  def perform()
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/fix_phenotypes_#{Rails.env}.log")

    Phenotype.all.each do |p|
        # is it empty?
        if p.user_phenotypes.length == 0
            # delete!
            log "Deleting phenotype '" + p.characteristic
            Phenotype.destroy(p)
            Sidekiq::Client.enqueue(Recommendvariations)
            Sidekiq::Client.enqueue(Recommendphenotypes)
            next
        end

        # is number_of_users still up-to-date?
        number_of_users = p.number_of_users
        current_number = p.user_phenotypes.all.length
        if number_of_users != current_number
            log "Updating number of users for phenotype '" + p.characteristic + "'"
            p.update_attributes(:number_of_users => current_number)
        end
    end
    
  end

  def log msg
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
