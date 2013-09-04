ActiveAdmin.register User do
  # show all users
  scope :all, :default => true

  index do
    column :name
    default_actions
  end
end
