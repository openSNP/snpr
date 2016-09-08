class SnpsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :find_snp, except: [:index, :json,:json_annotation]

  def index
    @snps = Snp.order(sort_column + ' ' + sort_direction)
    @snps_paginate = @snps.paginate(page: params[:page], per_page: 10)
    @title = 'Listing all SNPs'
  end

  def show
    @snp = Snp.includes(:snp_comments).
      where(name: params[:id].downcase).first || not_found

    if params[:format] == 'json'
      users = @snp.users
      json_results = users.map do |u|
        json_element(user_id: u.id, snp_name: @snp.name)
      end
      render json: json_results
      return
    end

    @title = @snp.name
    @comments = @snp.snp_comments.order('created_at ASC')
    @snp_comment = SnpComment.new

    if current_user
      # Refactor the following - fixes it for now. Problem with several genotypes. - Philipp
      @current_genotypes = current_user.genotypes
      if @current_genotypes != []
        @user_snp = @snp.user_snps.where(genotype_id: @current_genotypes.first.id).first
        @local_genotype = @user_snp.try(:local_genotype) || ''
      else
        @user_snp = nil
        @local_genotype = nil
      end
    end
  end

  def json
    # TODO: Refactor this. - Helge
    if params[:user_id].index(',')
      @user_ids = params[:user_id].split(',')
      @results = []
      @user_ids.each do |id|
        @new_param = {}
        @new_param[:user_id] = id
        @new_param[:snp_name] = params[:snp_name].downcase
        @results << json_element(@new_param)
      end
    elsif params[:user_id].index('-')
      @results = []
      @id_array = params[:user_id].split('-')
      @user_ids = (@id_array[0].to_i..@id_array[1].to_i).to_a
      @user_ids.each do |id|
        @new_param = {}
        @new_param[:user_id] = id
        @new_param[:snp_name] = params[:snp_name].downcase
        @results << json_element(@new_param)
      end
    else
      @results = json_element(params)
    end

    respond_to do |format|
      format.json { render json: @results }
    end
  end

  def make_annotation(result, snp, name)
    # TODO: Refactor this. - Helge
    result[name] = {}
    result[name]['name'] = snp.name
    result[name]['chromosome'] = snp.chromosome
    result[name]['position'] = snp.position
    result[name]['allele_frequency'] = snp.allele_frequency
    result[name]['genotype_frequency'] = snp.genotype_frequency
    result[name]['annotations'] = {}
    result[name]['annotations']['mendeley'] = []
    puts 'got snp-details'
    snp.mendeley_papers.each do |mp|
      @mendeley = {}
      @mendeley['author'] = mp.first_author
      @mendeley['title'] = mp.title
      @mendeley['publication_year'] = mp.pub_year
      @mendeley['number_of_readers'] = mp.reader
      @mendeley['open_access'] = mp.open_access
      @mendeley['url'] = mp.mendeley_url
      @mendeley['doi'] = mp.doi
      result[name]['annotations']['mendeley'] << @mendeley
    end
    puts 'got mendeley-details'
    result[name]['annotations']['plos'] = []
    snp.plos_papers.each do |mp|
      @plos = {}
      @plos['author'] = mp.first_author
      @plos['title'] = mp.title
      @plos['publication_date'] = mp.pub_date
      @plos['number_of_readers'] = mp.reader
      @plos['url'] = 'http://dx.doi.org/'+mp.doi
      @plos['doi'] = mp.doi
      result[name]['annotations']['plos'] << @plos
    end
    puts 'got plos-details'
    result[name]['annotations']['snpedia'] = []
    snp.snpedia_papers.each do |mp|
      snpedia = {}
      snpedia['url'] = mp.url
      snpedia['summary'] = mp.summary
      result[name]['annotations']['snpedia'] << snpedia
    end
    puts 'got snpedia-details'
    result[name]['annotations']['pgp_annotations'] = []
    snp.pgp_annotations.each do |p|
      @pgp = {}
      @pgp['gene'] = p.gene
      @pgp['impact'] = p.qualified_impact
      @pgp['inheritance'] = p.inheritance
      @pgp['trait'] = p.trait
      @pgp['summary'] = p.summary
      result[name]['annotations']['pgp_annotations'] << @pgp
    end
    puts 'got pgp details'
    result[name]['annotations']['genome_gov_publications'] = []
    snp.genome_gov_papers.each do |g|
      @gov = {}
      @gov['title'] = g.title
      @gov['first_author'] = g.first_author
      @gov['pubmed_link'] = g.pubmed_link
      @gov['publication_date'] = g.pub_date
      @gov['journal'] = g.journal
      @gov['trait'] = g.trait
      @gov['pvalue'] = g.pvalue
      @gov['pvalue_description'] = g.pvalue_description
      @gov['confidence_interval'] = g.confidence_interval
      result[name]['annotations']['genome_gov_publications'] << @gov
    end
    puts 'got genome.gov details'
    return result
  end

  def json_annotation
    result = {}
    if params[:snp_name].index(',')
      snps = params[:snp_name].split(',')
      snps.each do |s|
        snp = Snp.find_by_name(s)
        # did we get a SNP?
        if snp
          result = make_annotation(result, snp, snp.name)
        else
          # empty dictionary, else we get a half-filled dictionary for EXISTS, DOESN'T EXIST, EXISTS
          result = {}
          result['error'] = 'Sorry, we couldn\'t find SNP' + s
          # just stop. Alternative: we could put in one error per SNP?
          break
        end
      end
    else
      snp = Snp.find_by_name(params[:snp_name].downcase)
      if snp
        puts snp.name
        result = make_annotation(result, snp, 'snp')
      else
        result['error'] = 'Sorry, we couldn\'t find SNP ' + params[:snp_name]
      end
    end

    @result = result
    respond_to do |format|
      format.json { render json: @result }
    end
  end

  private

  def sort_column
    Snp.column_names.include?(params[:sort]) ? params[:sort] : 'ranking'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def json_element(params)
    # TODO: Refactor this. - Helge
    @result = {}
    begin
      @snp = params[:snp] || Snp.find_by_name(params[:snp_name].downcase)
      @result['snp'] = {}
      @result['snp']['name'] = @snp.name
      @result['snp']['chromosome'] = @snp.chromosome
      @result['snp']['position'] = @snp.position

      @user = User.find_by_id(params[:user_id])
      # Same hacky fix as above on line 35 - Philipp
      @genotypes = @user.genotypes
      if @genotypes != []
        @user_snps = @snp.user_snps.where(genotype_id: @genotypes.first.id)
      else
        @user_snps = []
      end
      @genotypes_array = []

      @user_snps.each do |us|
        @genotype_hash = {}
        @genotype_hash['genotype_id'] = us.genotype_id
        @genotype_hash['local_genotype'] = us.local_genotype
        @genotypes_array << @genotype_hash
      end

      @result['user'] = {}
      @result['user']['name'] = @user.name
      @result['user']['id'] = @user.id
      @result['user']['genotypes'] = @genotypes_array
    rescue
      @result = {}
      @result['error'] = 'Sorry, we couldn't find any information for SNP "+params[:snp_name].to_s+" and user "+params[:user_id].to_s"
    end
    return @result
  end

  def find_snp
    @snp = Snp.friendly.find(params[:id].downcase)
    @snp ||= Snp.find(params[:id])

    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    if request.path != snp_path(@snp)
      if request.path.index('.json') == nil
        return redirect_to @snp, status: :moved_permanently
      end
    end
  end
end
