class SnpsController < ApplicationController

	def index
		@snps = Snp.all

		respond_to do |format|
			format.html
			format.xml 
		end
	end
end
