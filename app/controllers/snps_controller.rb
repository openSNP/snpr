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
		@users = User.find(:all, :conditions => { :user_snp => { :snps => { :id => @snp.id }}}, :joins => [ :user_snps => :snp])

		respond_to do |format|
			format.html
			format.xml
		end
	end

end
