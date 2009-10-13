class UserSessionsController < InheritedResources::Base
  actions :new, :create, :destroy
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  create! do |success, failure|
    success.html { redirect_back_or_default root_url }
    failure.html { render :action => :new }
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = t('flash.user_sessions.destroy.notice')
    redirect_back_or_default new_user_session_url
  end
end
