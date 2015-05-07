ActiveAdmin.register Datafile do
  include AdminResource

  config.filters = false

  belongs_to :video

  controller do
    def create
      create! do |success, failure|
        @datafile.update_metadata(params[:datafile][:file].path) if !!params[:datafile] && !!params[:datafile][:file]
        success.html { redirect_to project_video_path(@video.project, @video) }
      end
    end

    def destroy
      destroy! do |success, failure|
        success.html { redirect_to project_video_path(@video.project, @video) }
      end
    end

    def update
      if request.xhr?
        update! do |success, failure|
          success.html { render nothing: true }
        end
      else
        update! do |success, failure|
          @datafile.update_metadata(params[:datafile][:file].path) if !!params[:datafile] && !!params[:datafile][:file].present?
          success.html { redirect_to project_video_path(@video.project, @video) }
        end
      end
    end

    def scoped_collection
      Datafile.unscoped
    end

    def find_resource
      @video = Video.find(params[:video_id])
      @video.datafiles.find(params[:id])
    end
  end

  form do |f|
    inputs do
      input :video_id, as: :hidden, value: params[:video_id]
      input :moving_average
      input :file,
            as: :file,
            input_html: {data: {prefix: "video-#{params[:video_id]}"}}
    end

    actions defaults: false do
      action :submit, button_html: { class: 'disabled', disabled: true }
      cancel_link
    end
  end
end
