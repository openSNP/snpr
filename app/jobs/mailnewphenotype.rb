require 'resque'

class Mailnewphenotype
  @queue = :mailnewgenotype

  def self.perform(phenotype_id,user_id)
    @phenotype = Phenotype.find_by_id(phenotype_id)
    User.where(:message_on_new_phenotype => true).find_each do |u|
      if u.id != user_id
        UserMailer.new_phenotype(@phenotype,u).deliver
      end
    end
  end
end