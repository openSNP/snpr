class SearchResultsController < ApplicationController

  def search
    @title = 'Search results'
    @all_len = 0
    [
      :snps, :phenotypes, :users, :snp_comments, :phenotype_comments,
      :mendeley_papers, :plos_papers, :snpedia_papers,
    ].each do |type|
      instance_variable_set(:"@#{type}", type.to_s.singularize.camelize.constantize.search(params[:search]))
      @all_len += instance_variable_get(:"@#{type}").length
    end
  end
end
