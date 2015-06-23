ActiveAdmin.register Tag do
  include AdminResource

  menu priority: 90

  filter :video, as: :select, collection: proc { Video.all }, label: 'Video'
  filter :name_cont, label: 'Name'
  filter :group_cont, label: 'Group'

  controller do
    def scoped_collection
      Tag.includes(:video).normal
    end
  end

  index do
    column :name do |tag|
      link_to tag, [ :edit, tag ]
    end
    column('Video'){ |tag| link_to tag.video.tester.name, project_video_path(tag.video.project, tag.video) }
    column 'Hierarchy' do |tag|
      tag.parent_tag.present? ? tag.hierarchy : ''
    end
    action_icons
  end

  form do |f|
    inputs do
      input :name
      input :parent_id, as: :select, collection:  Tag.orphans(f.object.video), label: 'Parent Tag', input_html: {class: 'polyselect'}
    end
    actions
  end

end