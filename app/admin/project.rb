ActiveAdmin.register Project do
  include AdminResource

  controller do
    def scoped_collection
      super.includes :customer
    end
  end

  index do
    selectable_column
    column :project do |project|
      link_to_if can?(:show, project), project, project
    end
    column :customer, sortable: 'customers.name' do |project|
      link_to_if can?(:show, project.customer), project.customer, project.customer
    end
    column :testers do |project|
      project.testers.count
    end
    column :type
    action_icons
  end

  show title: :to_s do
    h3 project.customer
    h4 'Videos'
    table_for project.videos.includes(:tester), class: 'index_table' do
      column :name do |video|
        link_to_if can?(:show, video), video.tester, [ project, video ]
      end
      column do |video|
        links = []
        links << link_to('Edit', [ :edit, project, video ]) if can?(:edit, video)
        links << link_to('Remove',
                         [ project, video ],
                         method: :delete, data: { confirm: 'Are you sure?' }
        ) if can?(:delete, video)
        links.join(' | ').html_safe
      end
    end

    para 'There are no videos for this project yet.' if project.videos.empty?

    div do
      link_to 'Add Video', new_project_video_path(project), class: 'button'
    end
  end

  form do |f|
    inputs do
      input :customer
      input :name
      input :type, input_html: {class: 'autocomplete', data: {prepopulate: Project.project_types}}
    end

    actions
  end

end
