ActiveAdmin.register Customer do
  include AdminResource

  filter :name

  index do
    selectable_column
    column :name do |customer|
      link_to_if can?(:show, customer), customer, customer
    end
    column :projects do |customer|
      customer.projects.count
    end
    action_icons
  end

  show title: :to_s do
    h3 'Projects'
    table_for customer.projects do
      column :name do |project|
        link_to_if can?(:show, project), project, project
      end
      column do |project|
        links = []
        links << link_to('Edit', [ :edit, project ]) if can?(:edit, project)
        links << link_to('Delete',
                         project,
                         method: :delete, data: { confirm: 'Are you sure?' }
        ) if can?(:delete, project)
        links.join(' | ').html_safe
      end
    end

    para 'There are no projects for this customer yet.' if customer.projects.empty?

    div do
      link_to 'Add Project', new_project_path(project: { customer_id: customer }), class: 'button'
    end
  end
end
