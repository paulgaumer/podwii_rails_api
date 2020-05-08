class ThemePolicy < ApplicationPolicy
  # class Scope < Scope
  #   def resolve
  #     scope.all
  #   end
  # end
  
  def update?
    record.podcast_id === user.podcasts.first.id
  end
end
