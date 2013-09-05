ActiveAdmin.register Genotype do
  # show all genotypes
  scope :all, :default => true

  index do
    column :user_id
    column :genotype_file_name
    column :genotype_content_type
    default_actions
  end
end
