ActiveAdmin.register User do
  include AdminResource

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  index do
    selectable_column
    id_column
    column :role do |user|
      status_tag user.role
    end
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :role do |user|
        status_tag user.role
      end
      row :reset_password_sent_at
      row :remember_created_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    inputs do
      input :email
      input :password
      input :password_confirmation
      input :role, collection: User::ROLES, include_blank: false
    end

    actions do
      action :submit
      cancel_link can?(:index, object) ? :users : :user
    end
  end
end
