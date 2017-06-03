# frozen_string_literal: true

class UpdatesController < ApplicationController
  def index
    @user_count = User.count
    @genotype_count = Genotype.count

    @new_genotypes = Genotype.order('id DESC').limit(20)
    @new_users = User.order('id DESC').limit(20)
    @new_phenotypes = Phenotype.order('id DESC').limit(20)
    @new_phenotype_comments = PhenotypeComment.order('id DESC').limit(20)
    @new_snp_comments = SnpComment.order('id DESC').limit(20)

    @newest_plos_paper = PlosPaper.order('id DESC').limit(20)
    @newest_mendeley_paper = MendeleyPaper.order('id DESC').limit(20)

    @newest_paper = @newest_mendeley_paper | @newest_plos_paper
    @newest_paper.sort! { |a, b| b.id <=> a.id }

    respond_to do |format|
      format.html
    end
  end
end
