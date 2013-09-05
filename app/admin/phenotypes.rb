ActiveAdmin.register Phenotype do
  # show all users
  scope :all, :default => true

  index do
    column :characteristic
    column :description
    default_actions
  end
end
