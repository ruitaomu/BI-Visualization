module ActiveAdminExtensions
  module Form
    extend ActiveSupport::Concern

    included do
      def input_with_policy(*args)
        if ApplicationPolicy.get(current_user, object).permitted_params.include?(args.first)
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
  end
end

ActiveAdmin::Views::ActiveAdminForm.send :include, ActiveAdminExtensions::Form
ActiveAdmin::Views::AttributesTable.send :include, ActiveAdminExtensions::AttributesTable
ActiveAdmin::Views::TableFor.send :include, ActiveAdminExtensions::TableFor
