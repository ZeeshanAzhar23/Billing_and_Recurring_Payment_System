class PlanPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def create?
    user.role == 'admin'
  end

  def new?
    create?
  end

  def update?
    @user.role == 'admin'
  end

  def edit?
    update?
  end
  def index?
    @user.role == 'admin' || @user.role == 'buyer'
  end

end
