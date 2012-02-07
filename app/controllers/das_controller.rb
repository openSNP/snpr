class DasController < ApplicationController

    def show
        @user = User.find_by_id(params[:id])
        @user_snps = @user.user_snps
        render :template => 'das/show.xml.erb', :layout => false
    end
end


