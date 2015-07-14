class UserSnpsController < ApplicationController
  def show
    @user_snps = UserSnp.where(user_id: current_user.id).paginate(page: params[:page])
  end

  def index
    if params[:snp_name].present?
      @local_genotype = params[:local_genotype].presence
      snp_name = ActiveRecord::Base.sanitize(params[:snp_name])
      @genotypes = Genotype.by_snp_name(params[:snp_name])
                           .select("snps -> #{snp_name} AS local_genotype")
                           .joins(:user)
      render layout: false
    else
      render text: 'Something went wrong.', layout: false
    end
  end
end
