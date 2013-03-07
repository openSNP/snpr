require 'resque'
require "recommendify"
Recommendify.redis = Redis.new

# our recommender class
class UserRecommender < Recommendify::Base

  max_neighbors 50

  input_matrix :users_to_phenotypes, 
    :similarity_func => :jaccard,
    :weight => 5.0

end

class Recommendphenotypes
  include Sidekiq::Worker
  sidekiq_options :queue => :recommendphenotypes

  def perform()
   recommender = UserRecommender.new
   
   #delete old items. this isn't the most efficient way to process this data, but for a test implementation it should work
   recommender.all_items.each do |i|
     recommender.delete_item!(i)
   end
  
   #iterate over all users to create similarity-matrix
     
   User.find_each do |u|
     @phenotype_array = []
     u.phenotypes.each do |p|
       @phenotype_array << p.id
     end
     recommender.users_to_phenotypes.add_set(u.id, @phenotype_array)
   end
   
   recommender.process!
  end
end
