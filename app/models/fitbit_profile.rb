class FitbitProfile < ActiveRecord::Base
  belongs_to :user
  has_many :fitbit_bodies
  has_many :fitbit_activities
  has_many :fitbit_sleeps
end