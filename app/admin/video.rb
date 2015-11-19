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

    def update
      if request.xhr?
        update! do |success, failure|
          success.html { render nothing: true }
        end
      else
        super
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
      links << link_to('Tag Series', [ :new, video, :tag_series ]) if can?(:edit, video)
      links << link_to('Remove',
                       [ video.project, video ],
                       method: :delete, data: { confirm: 'Are you sure?' }
      ) if can?(:delete, video)
      links.join(' | ').html_safe
    end
  end

  show title: -> (video) { video.tester.to_s } do
    video id: "video-#{resource.id}",
          class: 'video-js vjs-default-skin vjs-big-play-centered',
          preload: 'auto',
          width: '640',
          height: '480',
          'data-setup' => '{"controls": true, "controlBar": {"muteToggle": false}}' do

      source src: resource.url, type: 'video/mp4'
    end
    resource.datafiles.each do |datafile|
      div id: "datafile-#{datafile.id}"
        div class: 'datafile-actions' do
          span class: 'title' do
            datafile.metadata['title'].try :[], 0
          end
          dropdown_menu 'Actions' do
            item 'Edit', [ :edit, resource, datafile ] if can?(:edit, datafile)
            item 'Remove', [ resource,  datafile ], method: :delete, data: { confirm: 'Are you sure to remove this datafile?' } if can?(:delete, datafile)
          end
        end
        div class: 'datafile-chart', id: "datafile-chart-#{datafile.id}", 'data-video-id' => datafile.video_id
    end

    div do
      link_to 'Add Datafile', new_video_datafile_path(resource), class: 'button'
    end
    div render('dialog')
    form_for [ resource.project, resource ], html: { class: 'update-tags' } do
      button 'Save Video Tags'
    end
    div class: "chart #{'hidden' if resource.tags_for_chart.length < 1}", id: 'tag-chart', 'data-rows' => resource.tags_for_chart
    br
    div class: "#{'hidden' if resource.auto_tags_for_chart.length < 1}" do
      h3 'Automatic Tags'
      div class: 'auto-tag-chart', id: 'auto-tag-chart', 'data-rows' => resource.auto_tags_for_chart
    end
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
