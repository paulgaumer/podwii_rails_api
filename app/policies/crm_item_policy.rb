class CrmItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(podcast_id: user.podcasts.first)
    end
  end

  def create?
    true
  end
  
end
