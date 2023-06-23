class ProfileController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @connected_services = @user.services
  end
end
