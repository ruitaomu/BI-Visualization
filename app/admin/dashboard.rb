ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: I18n.t('active_admin.dashboard')

  content title: I18n.t('active_admin.dashboard') do
    columns do
      column do
        panel 'Customers' do
          ul do
            Customer.all.each do |customer|
              li link_to(customer, customer)
            end
          end
          para 'There are no customers yet.' unless Customer.any?
          div link_to('Create Customer', new_customer_path, class: 'button')
        end
      end

      column do
        panel 'Projects' do
          ul do
            Project.all.each do |project|
              li link_to(project, project)
            end
          end
          para 'There are no projects yet.' unless Project.any?
          div link_to('Create Project', new_project_path, class: 'button')
        end
      end
    end
  end
end
