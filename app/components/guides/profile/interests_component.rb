class Guides::Profile::InterestsComponent < ApplicationComponent
  def initialize(interests:)
    @interests = interests
  end

  private

  attr_reader :interests
end
