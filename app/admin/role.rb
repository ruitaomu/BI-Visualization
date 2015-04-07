ActiveAdmin.register Role do
  include AdminResource

  config.filters = false

  index do
    selectable_column
    column(:name) { |role| link_to role, role }
    column :permissions do |role|
      role.permissions.map do |permission|
        "#{permission.resource}: #{permission.actions.map(&:capitalize).join(', ')}"
      end.join(' / ')
    end
    action_icons
  end

  show title: :to_s do
    attributes_table do
      role.permissions.each do |permission|
        row(permission.resource) { permission.actions.map(&:capitalize).join(', ') }
      end
    end
  end

  form do |f|
    inputs do
      input :name
      has_many :permissions do |pf|
        pf.input :resource, collection: Role::RESOURCES
        pf.input :actions, as: :check_boxes, collection: Role::ACTIONS.map {|a| [a.capitalize, a]}
      end
    end
    actions
  end
end
