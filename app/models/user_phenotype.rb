class UserPhenotype < ActiveRecord::Base
  belongs_to :phenotype
  belongs_to :user
  validates_presence_of :variation

  attr_accessible :variation,:phenotype_id,:js_modal

  searchable do
    text :variation
    integer :phenotype_id
  end

  def give_me_user_phenotype(phenotype_id, user_id)
      # needed for the phenotype_set_forms
      @to_return = UserPhenotype.find_by_phenotype_id_and_user_id(phenotype_id, user_id)
      if @to_return == nil
          ""
      else
          @to_return.variation
      end
  end
end
