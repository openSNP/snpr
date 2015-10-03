class UserSnpsController < ApplicationController
  def show
    @user_snps = UserSnp.where(user_id: current_user.id).paginate(page: params[:page])
  end

  def index
    if params[:snp_name].present?
      @local_genotype = params[:local_genotype].presence
      @genotypes = Genotype.with_local_genotype_for(params[:snp_name])
                           .includes(:user)
      render layout: false
    else
      render text: 'Something went wrong.', layout: false
    end
  end
end
