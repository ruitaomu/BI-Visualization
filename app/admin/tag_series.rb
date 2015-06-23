ActiveAdmin.register TagSeries do
  include AdminResource

  config.filters = false

  belongs_to :video

  controller do
    before_filter :build_series, only: [:create, :new]
    def create
      create! do |success, failure|
        @tag_series.update_attributes(name: params[:tag_series][:name], tag_ids: params[:tag_series][:tag_ids].compact.reject(&:empty?)) if !!params[:tag_series][:tag_ids]
        success.html { redirect_to project_path(@tag_series.video.project) }
      end
    end

    def update
      if request.xhr?
        update! do |success, failure|
          success.html
        end
      else
        update! do |success, failure|
          @tag_series.update_attributes(name: params[:tag_series][:name], tag_ids: params[:tag_series][:tag_ids].compact.reject(&:empty?)) if !!params[:tag_series][:tag_ids]
          success.html { redirect_to project_path(@tag_series.video.project) }
        end
      end
    end

    def destroy
      destroy! do |success, failure|
        success.html { redirect_to project_path(@tag_series.video.project) }
      end
    end

    def find_resource
      @video = Video.find(params[:video_id])
      @tag_series = @video.tag_series
    end

    def build_series
      @video = Video.find(params[:video_id])
      @tag_series = @video.build_tag_series
    end

  end

  show title: -> (tag_series) { tag_series.name.to_s } do
    video id: "video-#{resource.video.id}",
          class: 'video-js vjs-default-skin vjs-big-play-centered',
          preload: 'auto',
          width: '640',
          height: '480',
          'data-setup' => '{"controls": true, "controlBar": {"muteToggle": false}}' do

      source src: resource.video.url, type: 'video/mp4'
    end
    resource.video.datafiles.each do |datafile|
      div class: 'datafile-actions' do
        dropdown_menu 'Datafile Actions' do
          item 'Edit', [ :edit, resource.video, datafile ] if can?(:edit, datafile)
          item 'Remove', [ resource.video,  datafile ], method: :delete, data: { confirm: 'Are you sure to remove this datafile?' } if can?(:delete, datafile)
        end
      end
      div class: 'datafile-chart', id: "datafile-chart-#{datafile.id}", 'data-video-id' => datafile.video_id
    end
    h3 "#{resource.name} Tag Series"
    div class: "auto-tag-chart tag_series #{'hidden' if resource.video.tag_series_for_chart.length < 1}", id: 'auto-tag-chart', 'data-rows' => resource.video.tag_series_for_chart
  end

  form do |f|
    inputs do
      input :name
      input :video_id, as: :hidden
      f.input :tag_ids, label: 'Tags', as: :select, collection: Tag.normal.where(video_id: f.object.video.id).map{|t| [t.name, t.id]}, multiple: true
    end

    actions
  end
end
