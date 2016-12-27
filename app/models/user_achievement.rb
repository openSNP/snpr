# frozen_string_literal: true
class UserAchievement < ActiveRecord::Base
   belongs_to :achievement
   belongs_to :user
end
