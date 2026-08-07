module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_admin?
  end

  private

  def require_admin
    return if Current.user&.admin?

    redirect_to root_path, alert: t("flash.authorization.admin_required")
  end

  def current_user_admin?
    Current.user&.admin?
  end
end
