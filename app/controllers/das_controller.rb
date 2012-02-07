class DasController < ApplicationController

    def show
        @user = User.find_by_id(params[:id])
        @user_snps = @user.user_snps
        render :template => 'das/show.xml.erb', :layout => false
        if params[:segment]
            @positions = params[:segment].split(":")
            @id = @positions[0]
            @start_and_end = @positions[1].split(",")
            @start = @start_and_end[0]
            @end = @start_and_end[1]
        else
            @id = 1
            @start = 2
            @end  = 3
        end
    end
end


