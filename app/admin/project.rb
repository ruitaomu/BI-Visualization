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
    column :customer, sortable: 'customers.name' do |project|
      link_to_if can?(:show, project.customer), project.customer, project.customer
    end
    column :testers do |project|
      project.testers.count
    end
    action_icons
  end

  show title: :to_s do
    h3 project.customer
    table_for project.testers, class: 'index_table' do
      column :name do |tester|
        link_to_if can?(:show, tester), tester, tester
      end
      column do |tester|
        links = []
        links << link_to('Edit', [ :edit, tester ]) if can?(:edit, tester)
        links << link_to('Delete',
                         tester,
                         method: :delete, data: { confirm: 'Are you sure?' }
        ) if can?(:delete, tester)
        links.join(' | ').html_safe
      end
    end

    para 'There are no testers for this customer yet.' if project.testers.empty?

    div do
      link_to 'Add Tester', new_tester_path(tester: { project_id: project }), class: 'button'
    end
  end
end
