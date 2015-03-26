module AdminResource
  def self.included(base)
    base.instance_eval do
      base.extend ClassMethods

      permit_params do
        policy.permitted_params
      end

      controller do
        def policy(subject = nil)
          ApplicationPolicy.get(current_user, subject || resource_class)
        end

        def can?(action, subject)
          policy(subject).try!("#{action}?")
        end
        helper_method :can?
      end
    end
  end

  module ClassMethods

  end
end
