ActiveAdmin.register Phenotype do
  # show all users
  scope :all, :default => true

  index do
    column :name
    column :description
    default_actions
  end
end
