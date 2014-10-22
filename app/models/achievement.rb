class Achievement < ActiveRecord::Base
  include PgSearch

  attr_accessible :award,:short_name
  has_many :user_achievements

  pg_search_scope :search, against: :award
end
