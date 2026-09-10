class Guides::Profile::BioComponent < ApplicationComponent
  def initialize(bio:)
    @bio = bio
  end

  def about_text
    tag.div(class: "mt-4 text-gray-700") do
      simple_format(bio.html_safe)
    end
  end

  private

  attr_reader :bio
end
