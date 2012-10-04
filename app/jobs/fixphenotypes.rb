require 'resque'

class Fixphenotypes
  @queue = :fixphenotypes

  def self.perform()
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/fix_phenotypes_#{Rails.env}.log")

    Phenotype.all.each do |p|
        # is it empty?
        if p.user_phenotypes.length == 0
            # delete!
            log "Deleting phenotype '" + p.characteristic
            Phenotype.destroy(p)
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

  def self.log msg
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
