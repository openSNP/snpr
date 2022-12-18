# frozen_string_literal: true
class UserPicturePhenotype < ApplicationRecord
  include PgSearchCommon

  belongs_to :picture_phenotype
  belongs_to :user

  has_attached_file :phenotype_picture, styles:
  { maximum: "1000x1000>", medium: "300x300>", thumb: "100x100>#",
    head: "32x32#" },
    default_url: '/images/standard_picture_phenotype_:style.png'
  validates_attachment_size :phenotype_picture, less_than: 1.megabyte
  validates_attachment_content_type :phenotype_picture ,
    content_type: ['image/jpeg', 'image/png', 'image/gif']

  pg_search_common_scope against: :picture_phenotype_id

  def give_me_user_phenotype(phenotype_id, user_id)
    # needed for the phenotype_set_forms
    @to_return = UserPicturePhenotype.find_by_phenotype_id_and_user_id(phenotype_id, user_id)
    if @to_return == nil
      ""
    else
      @to_return.phenotype_picture
    end
  end
end
