class DasController < ApplicationController

    def show
        @user = User.find_by_id(params[:id])
        @genotype = @user.genotypes.first

        # make arrays of positions and ids in case we have several
        # segments defined
        @positions = []
        @id = []
        @unkown_chromosome = []
        @known_chromosomes =  ('1'..'22').to_a << 'X' << 'MT' << 'Y'
        # user_snps is an array of arrays, each inner array having all user_snps from one specified segment
        @user_snps = []
        @has_start = []
        @start_and_end = []

        # first, split up all segments if they are present
        # TODO: Refactor this - Philipp
        if request.query_string
            @query_string = CGI.parse request.query_string
            @types = []

                @query_string['type'].each do |t|
                  @types << t
                end

                @query_string['segment'].each do |q|
                   @pos = q.split(':')
                   # append chromosome-id to the array of ids
                   @id << @pos[0]
                   if @known_chromosomes.include? @pos[0]
                       @unkown_chromosome << false
                   else
                       @unkown_chromosome << true
                   end

                   if @pos[1] != nil
                       @start_and_end << @pos[1].split(',')
                       @start = @pos[1].split(',')[0]
                       @end = @pos[1].split(',')[1]
                       @has_start << true
                       @snps = @user.snps.where('CAST(position as integer) <= ? AND CAST(position as integer) >= ? AND CAST(chromosome as text) = ?', @end, @start, @pos[0])
                       @tmp_user_snps = []
                       @snps.each do |s|
                           # 2014-8-26 There are several UserSNPs. Just take first one. - Philipp
                           if @types != []
                             @single_user_snp = s.user_snps.find_by_genotype_id(@genotype.id)
                             if @types.include? @single_user_snp.local_genotype
                               @tmp_user_snps << @single_user_snp
                             end
                           else
                             @tmp_user_snps << s.user_snps.find_by_genotype_id(@genotype.id)
                           end
                       end

                       @user_snps << @tmp_user_snps
                    else
                       # there are no positions, so use only chromosome
                       @snps = @user.snps.where('CAST(chromosome as text) = ?', @id)
                       @tmp_user_snps = []

                       @snps.each do |s|
                           # there is only one user_snp for each snps
                           if @types != []
                             @single_user_snp = s.user_snps.find_by_genotype_id(@genotype.id)
                             if @types.include? @single_user_snp.local_genotype
                               @tmp_user_snps << @single_user_snp
                             end
                           else
                             @tmp_user_snps << s.user_snps.find_by_genotype_id(@genotype.id)
                           end
                       end

                       @user_snps << @tmp_user_snps
                       @has_start << false
                    end
            end
        # When everything went correctly, send back 200
        response.headers['X-DAS-Status'] = '200'
    else
        # no chromosome or start/end, so get nothing
            @user_snps = [] #@user.user_snps
            @id = ''
            @start = ''
            @end  = ''

            # Bad command arguments (arguments invalid)
            response.headers['X-DAS-Status'] = '402'
        end
        response.headers['X-DAS-Version'] = 'DAS/1.53E'
        # Change these capabilities once we implement more
        response.headers['X-DAS-Capabilities'] = 'features/1.1; sources/1.0'
        # Put in the servername and version
        response.headers['X-DAS-Server'] = request.env['SERVER_SOFTWARE'].split(' ')[0]
        response.headers['Access-Control-Allow-Origin'] = '*'

        render :template => 'das/show.xml.erb', :layout => false
    end

    def sources
        @users = User.all
        response.headers['X-DAS-Version'] = 'DAS/1.53E'
        response.headers['X-DAS-Status'] = '200'
        response.headers['X-DAS-Capabilities'] = 'features/1.1; sources/1.0'

        response.headers['X-DAS-Server'] = request.env['SERVER_SOFTWARE'].split(' ')[0]

        render :template => 'das/sources.xml.erb', :layout => false
    end

    def startpoint
      @user = User.find_by_id(params[:id])
      response.headers['X-DAS-Version'] = 'DAS/1.53E'
      response.headers['X-DAS-Status'] = '200'
      response.headers['X-DAS-Capabilities'] = 'features/1.1; sources/1.0'
      response.headers['X-DAS-Server'] = request.env['SERVER_SOFTWARE'].split(' ')[0]

      render :template => 'das/startpoint.xhtml.erb', :layout => false
    end
end
