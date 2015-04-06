

class Mailnewphenotype
  include Sidekiq::Worker
  sidekiq_options queue: :mailnewgenotype, unique: true, retry: false # avoid spam on breakage

  def perform(phenotype_id, user_id)
    @phenotype = Phenotype.find_by_id(phenotype_id)
    User.where(message_on_new_phenotype: true).find_each do |u|
      if u.id != user_id
        UserMailer.new_phenotype(@phenotype, u).deliver_later
      end
    end
  end
end
