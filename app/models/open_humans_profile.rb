# frozen_string_literal: true

class OpenHumansProfile < ActiveRecord::Base
  belongs_to :user
end
