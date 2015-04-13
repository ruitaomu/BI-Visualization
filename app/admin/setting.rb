ActiveAdmin.register Setting do
  include AdminResource

  menu priority: 90

  config.filters = false

  controller do
    def update
      update! do |success, failure|
        success.html { redirect_to settings_path }
      end
    end
  end

  index do
    column :name do |setting|
      link_to setting, [ :edit, setting ]
    end
    column :value
  end

  form title: 'wat' do |f|
    inputs do
      input :name, input_html: { disabled: true }
      input :value
    end
    actions
  end
end
