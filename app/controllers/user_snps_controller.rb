class UserSnpsController < ApplicationController
	def show
		@user_snps = UserSnp.where(:user_id => current_user.id).paginate(:page => params[:page])
	end

  def index
    @local_genotype = params[:local_genotype].presence
    if params[:snp_name].present?
      @user_snps = UserSnp.joins(:snp).
        where(['snps.name = ?', params[:snp_name]]).includes(:user)
      render layout: false
    else
      render text: "Something went wrong.", layout: false
    end
  end
end
