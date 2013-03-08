
require "recommendify"
Recommendify.redis = Redis.new

# our recommender class
class UserRecommender < Recommendify::Base

  max_neighbors 50

  input_matrix :users_to_variations, 
    :similarity_func => :jaccard,
    :weight => 5.0

end

class Recommendvariations
  include Sidekiq::Worker
  sidekiq_options :queue => :recommendvariations

  def perform()
   recommender = UserRecommender.new
   
   #delete old items. this isn't the most efficient way to process this data, but for a test implementation it should work
   recommender.all_items.each do |i|
     recommender.delete_item!(i)
   end
  
   #iterate over all users to create similarity-matrix
     
   User.find_each do |u|
     @phenotype_array = []
     u.user_phenotypes.each do |up|
       @phenotype_array << up.phenotype.id.to_s+"=>"+up.variation
     end
     recommender.users_to_variations.add_set(u.id, @phenotype_array)
   end
   
   recommender.process!
  end
end
