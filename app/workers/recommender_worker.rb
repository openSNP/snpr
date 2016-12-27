# frozen_string_literal: true
class RecommenderWorker
  include Sidekiq::Worker
  sidekiq_options queue: :recommend, retry: 5, unique: :until_executed

  def perform(recommender_class)
    recommender_class.constantize.new.update
  end
end
