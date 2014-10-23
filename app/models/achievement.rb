class Achievement < ActiveRecord::Base
  include PgSearchCommon

  attr_accessible :award,:short_name
  has_many :user_achievements

  pg_search_common_scope against: :award
end
