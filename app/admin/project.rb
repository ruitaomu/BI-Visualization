ActiveAdmin.register Project do
  include AdminResource

  controller do
    def scoped_collection
      super.includes :customer
    end
  end

  index do
    selectable_column
    column :name do |project|
      link_to_if can?(:show, project), project, project
    end
    column :customer, sortable: 'customers.id' do |project|
      link_to_if can?(:show, project.customer), project.customer, project.customer
    end
    action_icons
  end

  show title: :to_s do
    attributes_table do
      row :id
      row :name
      row :customer
      row :created_at
      row :updated_at
    end
  end
end
