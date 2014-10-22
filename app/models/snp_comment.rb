class SnpComment < ActiveRecord::Base
  include PgSearch

  belongs_to :snp
  belongs_to :user

  pg_search_scope :search, against: :subject
end
