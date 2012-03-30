require_relative '../test_helper'

class UserPhenotypeTest < ActiveSupport::TestCase
  context "UserPhenotype" do
    setup do
      @phenotype = Factory :phenotype
      @user_phenotype_0 = Factory :user_phenotype,
        phenotype_id: @phenotype.id, variation: 'foo-bar'
      @user_phenotype_1 = Factory :user_phenotype,
        phenotype_id: @phenotype.id, variation: 'Foo Bar'
      @user_phenotype_2 = Factory :user_phenotype,
        phenotype_id: @phenotype.id + 1, variation: 'Foo Bar'
      Sunspot.commit
    end

    should "find similar user phenotypes" do
      phenotype = @phenotype
      results = UserPhenotype.search do
        with(:phenotype_id, phenotype.id)
        fulltext 'foo bar'
      end.results
      assert_equal [@user_phenotype_0, @user_phenotype_1], results.sort_by(&:id)
    end
  end
end
