class DasController < ActionController::Base

    def show
        @user = User.find_by_id(params[:id])
        @user_snps = @user.user_snps

        respond_to do |format|
            format.xml
        end
    end
end


