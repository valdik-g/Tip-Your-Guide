class Guides::Profile::AboutMeComponent < ApplicationComponent
  def initialize(guide:)
    @guide = guide
  end

  private

  attr_reader :guide
end
