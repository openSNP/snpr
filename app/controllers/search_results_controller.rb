require "file_sender"

class SearchResultsController < ApplicationController

  def search_type(type)
	  type.solr_search { |p| p.keywords params[:search] }
  end

  def search
	  @title = "Search results"

          [ Snp, Phenotype, User, UserPhenotype, SnpComment, PhenotypeComment,
            MendeleyPaper, PlosPaper, SnpediaPaper
          ].each do |klass|
            instance_variable_set "@#{klass.to_s.underscore.pluralize}", search_type(klass)
          end
  end
 

end
