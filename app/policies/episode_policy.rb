class EpisodePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def create?
    # Any logged in can create a podcast as long as user exists
    record.podcast == user.podcasts.first
  end
  
  def update?
    record.podcast == user.podcasts.first
  end
end
