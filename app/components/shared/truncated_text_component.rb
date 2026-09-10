module Shared
  class TruncatedTextComponent < ApplicationComponent
    attr_reader :id, :text, :max_height, :container_classes, :content_classes

    def initialize(id:, text:, max_height: 100, container_classes: "", content_classes: "")
      @id = id
      @text = text
      @max_height = max_height
      @container_classes = container_classes
      @content_classes = content_classes
    end

    def show_more_text
      t("views.shared.truncated_text.show_more")
    end

    def show_less_text
      t("views.shared.truncated_text.show_less")
    end
  end
end
