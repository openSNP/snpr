# frozen_string_literal: true
class DeleteGenotype
  include Sidekiq::Worker
  sidekiq_options queue: :user_snps, retry: 5, unique: true

  def perform(params)
    Genotype.transaction do
      genotype = Genotype.find(params['genotype_id'])
      user = genotype.user

      if user.genotypes.count == 1
        # update user-attributes
        user.update_attributes(has_sequence: false, sequence_link: nil)

        # delete Uploaded Genotyping-achievement
        achievement = Achievement.where(award: 'Published genotyping')
        UserAchievement.where(achievement: achievement, user: user).destroy_all
      end

      genotype.destroy
    end
  end
end
