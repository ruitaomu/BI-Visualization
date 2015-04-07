ActiveAdmin.register User do
  include AdminResource

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  index do
    selectable_column
    column :email do |user|
      link_to user.email, user
    end
    column :role do |user|
      status_tag user.role
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at

    action_icons
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
      if current_user.id == user.id
        input :password
        input :password_confirmation
      end
      input :roles, collection: Role.all
    end

    actions do
      action :submit
      cancel_link can?(:index, object) ? :users : :user
    end
  end
end
