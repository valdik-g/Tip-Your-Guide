class Shared::IconComponent < ApplicationComponent
  def initialize(name, color: "gray", size: 18)
    @name = name
    @color = color
    @size = size
  end

  def icon
    tag.span(class: "text-#{color} mb-1") do
      helpers.lucide_icon(name, size:)
    end
  end

  private

  attr_reader :name, :color, :size
end
