require_relative '../test_helper'

class PhenotypeTest < ActiveSupport::TestCase
  context "Phenotype" do
    setup do
      @phenotype = FactoryGirl.create(:phenotype)
      @phenotype.instance_variable_set(:@known_phenotypes, nil)
    end

    should "know some phenotypes" do
      @phenotype.user_phenotypes.create(variation: "Ping pong")
      @phenotype.user_phenotypes.create(variation: "ping pong")
      assert_equal ["Ping pong"], @phenotype.known_phenotypes
    end
  end
end
