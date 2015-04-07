module ActiveAdminExtensions
  module Form
    extend ActiveSupport::Concern

    included do
      def input_with_policy(*args)
        if ApplicationPolicy.get(current_user, object).permitted_param?(args.first)
          input_without_policy *args
        end
      end
      alias_method_chain :input, :policy
    end
  end

  module AttributesTable
    extend ActiveSupport::Concern

    included do
      def row_with_policy(*args, &block)
        record = @collection.first
        if ApplicationPolicy.get(current_user, record).visible_attribute?(args.first)
          row_without_policy *args, &block
        end
      end
      alias_method_chain :row, :policy
    end
  end

  module TableFor
    extend ActiveSupport::Concern

    included do
      def column_with_policy(*args, &block)
        if ApplicationPolicy.get(current_user, @resource_class).visible_attribute?(args.first)
          column_without_policy *args, &block
        end
      end
      alias_method_chain :column, :policy
    end

    def action_icons
      actions defaults: false, class: 'action-icons' do |record|
        if can?(:edit, record)
          item icon('pen'), [ :edit, record ], title: I18n.t('active_admin.edit')
        end
        if can?(:destroy, record)
          item icon('trash_stroke'), record, title: I18n.t('active_admin.delete'), method: :delete, data: { confirm: I18n.t('active_admin.delete_confirmation') }
        end
        if block_given?
          yield record
        end
      end
    end
  end
end

ActiveAdmin::Views::ActiveAdminForm.send :include, ActiveAdminExtensions::Form
ActiveAdmin::Views::AttributesTable.send :include, ActiveAdminExtensions::AttributesTable
ActiveAdmin::Views::TableFor.send :include, ActiveAdminExtensions::TableFor
