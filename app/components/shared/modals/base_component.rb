class Shared::Modals::BaseComponent < ApplicationComponent
  def initialize(id:, header: nil, size: :md, frame: true)
    @id = id
    @header = header
    @size = size
    @frame = frame
  end

  private

  attr_reader :id, :header, :size, :frame

  def content_classes
    base =
      if frame
        "modal-content bg-white rounded-xl shadow-xl p-4 relative w-full max-h-[100vh] overflow-y-auto mx-4 transform transition-transform duration-300 ring-1 ring-zinc-950/20"
      else
        "modal-content relative max-h-[100vh] overflow-y-auto mx-0"
      end

    size_class =
      case size.to_sym
      when :sm then "max-w-sm"
      when :lg then "max-w-lg"
      when :xl then "max-w-xl"
      when :full then "max-w-none"
      else "max-w-md"
      end

    "#{base} #{size_class}"
  end

  def frame?
    frame
  end

  def render_close_button
    view_context.button_tag(
      type: "button", class: "close-button absolute top-3 right-3 text-gray-200 hover:text-white transition-colors p-1 rounded-full hover:bg-black/30 z-10",
      data: {controller: "modal", action: "click->modal#close", modal_id: id},
      aria: {label: "Close"}
    ) do
      view_context.content_tag(:div, class: "bg-gray-50 w-8 h-8 rounded-full inline-flex items-center justify-center text-xl") do
        render Shared::IconComponent.new("x", color: "gray-400", size: 24)
      end
    end
  end
end
