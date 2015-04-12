ActiveAdmin.register Video do
  include AdminResource

  config.filters = false

  belongs_to :project

  controller do
    def create
      create! do |success, failure|
        success.html { redirect_to project_path(@project) }
      end
    end

    def scoped_collection
      super.includes :project
    end

    def find_resource
      @project = Project.find(params[:project_id])
      @project.videos.find(params[:id])
    end
  end

  index do
    selectable_column
    column :video do |video|
      link_to_if can?(:show, video), video.tester, [ video.project, video ]
    end
    column do |video|
      links = []
      links << link_to('Edit', [ :edit, video.project, video ]) if can?(:edit, video)
      links << link_to('Remove',
                       [ video.project, video ],
                       method: :delete, data: { confirm: 'Are you sure?' }
      ) if can?(:delete, video)
      links.join(' | ').html_safe
    end
  end

  show do

  end

  form do |f|
    inputs do
      testers = Tester.where.not(id: f.object.project.tester_ids - [ f.object.tester_id ])
      input :tester, collection: testers
      input :url, as: :hidden
      input :file,
            as: :file,
            input_html: {
              data: {
                signer: s3_signatures_path,
                prefix: "project-#{f.object.project_id}",
                s3_key: ENV['S3_ACCESS_KEY'],
                s3_host: ENV['S3_HOST'],
                s3_bucket: ENV['S3_BUCKET']
              }
            }
    end

    actions defaults: false do
      action :submit, button_html: { class: 'disabled', disabled: true }
      cancel_link
    end
  end
end
