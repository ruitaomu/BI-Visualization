ActiveAdmin.register Tester do
  include AdminResource

  index do
    selectable_column
    column :name do |tester|
      link_to_if can?(:show, tester), tester, tester
    end
    column :projects do |tester|
      link_to_if can?(:show, Project), tester.projects.count, projects_path(tester_id: tester.id)
    end
    action_icons
  end

  show title: :to_s do
    attributes_table do
      row :id
      row :name
      row :projects
      Setting.tester_attributes.each do |attr|
        row attr do |tester|
          (tester.metadata || {})[attr]
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    inputs do
      input :name
      Setting.tester_attributes.each do |attr|
        input :"metadata_#{attr}", label: attr.humanize
      end
    end
    actions
  end
end
