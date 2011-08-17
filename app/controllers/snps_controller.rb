
class SnpsController < ApplicationController

	def index
		#@snps = Snp.all
		@snps = Snp.paginate(:page => params[:page])

		respond_to do |format|
			format.html
			format.xml 
		end
	end
end
