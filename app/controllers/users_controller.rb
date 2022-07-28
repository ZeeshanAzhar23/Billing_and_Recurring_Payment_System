class UsersController < ApplicationController
  before_action :find_user, only: [:show,:destroy,:edit,:update]
  around_action :delete_stripe_customer, only: [:destroy]
  #before_action :authorize_admin, only: [:index]



  def index
    @users= User.all
    authorize @users
  end

  def show


  end

  def edit
    # @user=User.find(params[:id])
    authorize @user
  end

  def update
    @user=User.find(params[:id])
    authorize @user
    if @user.update(user_params)
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_path
    end

  end

  private def user_params
    params.require(:user).permit(:name,:email)
  end

  private def find_user
    @user=User.find(params[:id])
  end

  private def authorize_admin
    return unless !current_user.admin?
    redirect_to root_path, alert: 'Admins only!'
  end


end
