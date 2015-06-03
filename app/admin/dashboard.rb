ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: I18n.t('active_admin.dashboard')

  content title: I18n.t('active_admin.dashboard') do
    columns do
      column do
        h3 'Project Types'
        para 'There are no project Types present yet.' if Project.types.empty?

        Project.types.sort.reverse.each do |type|
          table_for Project.unarchived(type), class: 'index_table' do
            column "#{type.blank? ? 'No project type' : type}" do |project|
              link_to(project, project) +
              link_to('archive', project_path(project, project: {archived: true}), method: :put, remote: true,
                      data: {confirm: 'Are you sure you want to archive this project?'}, class: 'status_tag yes pull-right' )
            end
          end
          br
        end

      end
    end
  end
end
