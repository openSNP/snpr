class DasController < ApplicationController

    def show
        @user = User.find_by_id(params[:id])
        if params[:segment]
            @user_snps = @user.user_snps.find(:all)
            @positions = params[:segment].split(":")
            @id = @positions[0]
            @start_and_end = @positions[1].split(",")
            @start = @start_and_end[0]
            @end = @start_and_end[1]
        else
            @user_snps = @user.user_snps.find(:all)
            @id = ""
            @start = ""
            @end  = ""
        end
        render :template => 'das/show.xml.erb', :layout => false
    end
end


