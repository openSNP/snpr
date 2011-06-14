class StaticController < ApplicationController
	def index
		@title = "Welcome"
		respond_to do |format|
			format.html
			format.xml # just for the hell of it
		end
	end

	def faq
		@title = "FAQ"
		respond_to do |format|
			format.html
			format.xml
		end
	end
end
