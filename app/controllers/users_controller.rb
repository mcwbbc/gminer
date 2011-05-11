class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:show]

  def show
    @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'That user does not exist.'
      redirect_to(root_path)
  end

end
