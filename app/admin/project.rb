ActiveAdmin.register Project do
  include AdminResource

  action_item :archive, only: :show do
    link_to(resource.archived? ? 'Unarchive' : 'Archive',
            project_path(resource, project: { archived: !resource.archived? }), method: :put)
  end

  controller do
    def scoped_collection
      super.includes :customer
    end

    def update
      if request.xhr?
        update! do |success, failure|
          success.js { request.referer.include?('dashboard') ? (render 'update_dashboard') : (render nothing: true) }
        end
      else
        super
      end
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
    column :archived
    action_icons
  end

  show title: :to_s do
    tabs do
      tab 'General' do
        table_for project.videos.includes(:tester), class: 'index_table' do
          column :name do |video|
            link_to_if can?(:show, video), video.tester, [ project, video ]
          end
          column 'Tag Series' do |video|
            links = []
            links << link_to('Create', [ :new, video, :tag_series ]) if can?(:edit, video) && !video.tag_series.present?
            links << link_to('Show', [ video, video.tag_series]) if can?(:edit, video) && video.tag_series.present?
            links << link_to('Edit', [ :edit, video, video.tag_series ]) if can?(:edit, video) && video.tag_series.present?
            links << link_to('Remove', [ video, video.tag_series ], method: :delete) if can?(:edit, video) && video.tag_series.present?
            links.join(' | ').html_safe
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
        br
        div render('video_tags_listing')
      end
      tab 'Data'
    end
  end

  form do |f|
    inputs do
      input :customer
      input :name
      input :type, input_html: {class: 'autocomplete', data: {prepopulate: Project.project_types}}
      input :archived
      Setting.project_attributes.each do |attr|
        input :"metadata_#{attr}", label: attr.humanize
      end
    end

    actions
  end

end
