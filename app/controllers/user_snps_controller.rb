class UserSnpsController < ApplicationController
  def show
    @user_snps = UserSnp.where(user_id: current_user.id).paginate(page: params[:page])
  end

  def index
    if params[:snp_name].present?
      @local_genotype = params[:local_genotype].presence
      snp_name = ActiveRecord::Base.sanitize(params[:snp_name])
      genotype_ids = Snp.unscoped
                        .select('unnest(genotype_ids) AS genotype_ids')
                        .where(name: params[:snp_name])
                        .limit(1)
      @genotypes = Genotype.select("snps -> #{snp_name} AS local_genotype")
                           .joins(:user)
                           .where(id: genotype_ids)
      render layout: false
    else
      render text: 'Something went wrong.', layout: false
    end
  end
end
