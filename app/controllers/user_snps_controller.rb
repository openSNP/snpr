class UserSnpsController < ApplicationController
	def show
		@user_snps = UserSnp.where(:user_id => current_user.id).paginate(:page => params[:page])
	end
end
