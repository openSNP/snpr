# frozen_string_literal: true
class Achievement < ActiveRecord::Base
  include PgSearchCommon
  has_many :user_achievements
  pg_search_common_scope against: :award
end
