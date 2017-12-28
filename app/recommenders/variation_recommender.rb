# frozen_string_literal: true
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

  def self.recommendations_for(user_phenotype, count)
    neighbors = new
                .for("#{user_phenotype.phenotype_id}=>#{user_phenotype.variation}")
                .take(count)
    phenotype_ids = neighbors.map(&method(:phenotype_id_from_neighbor))
    phenotypes = Phenotype.find(phenotype_ids).index_by(&:id)

    neighbors.map do |neighbor|
      phenotype = phenotypes.fetch(phenotype_id_from_neighbor(neighbor))
      Recommendation.new(neighbor, phenotype)
    end
  end

  def self.phenotype_id_from_neighbor(neighbor)
    neighbor.item_id.split('=>').first.to_i
  end

  private

  class Recommendation
    attr_reader :phenotype

    def initialize(neighbor, phenotype)
      @neighbor = neighbor
      @phenotype = phenotype
    end

    def variation
      neighbor.item_id.split('=>').last
    end

    private

    attr_reader :neighbor
  end
end
