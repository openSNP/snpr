class SnpsController < ApplicationController
	def index
		@snps = Snp.paginate(:page => params[:page])

		respond_to do |format|
			format.html
			format.xml 
		end
	end
	
	def show
		@snp = Snp.find_by_id(params[:id])
		@users = User.where(:id => UserSnp.where(:snp_id => @snp.id).all) #works without returning a specific user_id! huh
		# @users sometimes returns the correct results, sometimes doesn't
		# weird

		respond_to do |format|
			format.html
			format.xml
		end
	end

end
