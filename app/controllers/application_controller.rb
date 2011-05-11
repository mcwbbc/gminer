class ApplicationController < ActionController::Base
  protect_from_forgery

  def admin_required
    unless admin?
      flash[:warning] = "This action requires administration access."
      redirect_to root_url and return false
    end
  end

  def user_signed_in?
    !!current_user
  end

  def admin?
    !current_user.blank? && current_user.admin?
  end

  def me?(user)
    user == current_user
  end

  helper_method :user_signed_in?, :admin?, :me?

end
