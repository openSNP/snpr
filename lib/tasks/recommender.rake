namespace :recommender do
  task update_all: :environment do
    RecommenderWorker.perform_async('PhenotypeRecommender')
    RecommenderWorker.perform_async('VariationRecommender')
  end
end
