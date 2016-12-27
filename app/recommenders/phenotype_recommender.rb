# frozen_string_literal: true
class PhenotypeRecommender < Recommendify::Base
  include RecommenderDeleteItems

  max_neighbors 50
  input_matrix :users_to_phenotypes, similarity_func: :jaccard, weight: 5.0

  def update
    delete_items

    User.joins(:phenotypes)
        .group('users.id')
        .pluck('users.id', 'array_agg(phenotypes.id)')
        .each do |user_id, phenotype_ids|
          users_to_phenotypes.add_set(user_id, phenotype_ids)
        end

    process!
  end
end
