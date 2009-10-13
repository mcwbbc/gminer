class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  
  def new
  end
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = t('flash.password_resets.create.notice')
      redirect_to root_url
    else
      flash[:warning] = t('flash.password_resets.create.error')
      render :action => :new
    end
  end
  
  def edit
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if !@user.password.blank? && @user.save
      @user.reset_perishable_token!
      flash[:notice] = t('flash.password_resets.update.notice')
      redirect_to account_url
    else
      flash[:warning] = t('flash.password_resets.update.error') if @user.password.blank?
      render(:action => :edit)
    end
  end

private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:warning] = t('flash.require_user_token')
      redirect_to root_url
    end
  end
end
