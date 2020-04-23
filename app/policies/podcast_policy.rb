class PodcastPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # scope.all
      scope.where(user: user)
    end
  end

  def show?
    record.user == user
  end

  def landing_page?
    true
  end
  def landing_page_single_episode?
    landing_page?
  end

  def update?
    record.user == user
  end

  def create?
    # Any logged in can create a podcast as long as user exists
    !user.nil?
  end

  def destroy?
    update?
  end
end
