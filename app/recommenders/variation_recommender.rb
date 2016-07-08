class VariationRecommender < Recommendify::Base
  include RecommenderDeleteItems

  max_neighbors 50
  input_matrix :users_to_variations, similarity_func: :jaccard, weight: 5.0

  def update
    delete_items

    User.joins(user_phenotypes: :phenotype)
        .group('users.id')
        .pluck('users.id', "array_agg(CONCAT(phenotypes.id, '=>', user_phenotypes.variation))")
        .each do |user_id, phenotype_array|
          users_to_variations.add_set(user_id, phenotype_array)
        end

    process!
  end

end
