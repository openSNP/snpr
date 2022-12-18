# frozen_string_literal: true
class UserAchievement < ApplicationRecord
   belongs_to :achievement
   belongs_to :user
end
