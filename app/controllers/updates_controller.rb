class UpdatesController < ApplicationController
  def index
    @new_genotypes = Genotype.order('created_at DESC').limit(20)
    @new_users = User.order('created_at DESC').limit(20)
    @new_phenotypes = Phenotype.order('created_at DESC').limit(20)
    @new_phenotype_comments = PhenotypeComment.order('created_at DESC').limit(20)
    @new_snp_comments = SnpComment.order('created_at DESC').limit(20)

    @newest_plos_paper = PlosPaper.order('created_at DESC').limit(20)
    @newest_mendeley_paper = MendeleyPaper.order('created_at DESC').limit(20)

    @newest_paper = @newest_mendeley_paper | @newest_plos_paper
    @newest_paper.sort! { |a,b| b.created_at <=> a.created_at }

    respond_to do |format|
      format.html
    end
  end
end
