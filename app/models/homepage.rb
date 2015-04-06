class Homepage < ActiveRecord::Base
  belongs_to :user
  after_save :destroy_if_blank

  validates_uniqueness_of :description, :url

  private

  def destroy_if_blank
    destroy if url.blank?
  end
end
