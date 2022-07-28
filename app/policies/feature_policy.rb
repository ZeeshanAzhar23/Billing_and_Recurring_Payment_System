class FeaturePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def create?
    @user.role == 'admin'
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

end
