ActiveAdmin.register Tester do
  include AdminResource

  controller do
    def scoped_collection
      super.includes :project
    end
  end

  index do
    selectable_column
    column :name do |tester|
      link_to_if can?(:show, tester), tester, tester
    end
    column :project, sortable: 'testers.name' do |tester|
      link_to_if can?(:show, tester.project), tester.project, tester.project
    end
    action_icons
  end

  show title: :to_s do
    attributes_table do
      row :id
      row :name
      row :project
      row :created_at
      row :updated_at
    end
  end
end
