class Shared::TagComponent < ApplicationComponent
  def initialize(text:)
    @text = text
  end

  def styles
    "bg-gray-100 text-gray-700 px-3 py-1 rounded-lg text-sm outline outline-2 outline-gray-400"
  end

  private

  attr_reader :text
end
