# frozen_string_literal: true

class Homepage < ApplicationRecord
   belongs_to :user
   after_save :destroy_if_blank

   validates_uniqueness_of :description, :url
   private

   def destroy_if_blank
     self.destroy if url.blank?
   end
end
