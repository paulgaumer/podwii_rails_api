class RestaurantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # scope.all
      scope.where(user: user)
    end
  end

  def show?
    record.user == user
  end

  def update?
    record.user == user
  end

  def create?
    # Any logged in can create a restaurant as long as user exists
    !user.nil?
  end

  def destroy?
    update?
  end
end
