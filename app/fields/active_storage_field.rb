require "administrate/field/base"

class ActiveStorageField < Administrate::Field::Base
  def to_s
    data
  end

  def url
    return nil unless attachable?

    Rails.application.routes.url_helpers.url_for(resource.send(attribute))
  end

  def variant_url(options)
    return nil unless attachable?

    # HEIC & HEIF often cause libvips/libheif crashes during processing. Until we
    # implement a robust server-side transcoding pipeline, просто отдаём
    # оригинальный файл, чтобы не ломать интерфейс.
    if resource.send(attribute).blob.content_type.in?(%w[image/heic image/heif])
      return Rails.application.routes.url_helpers.url_for(resource.send(attribute))
    end

    Rails.application.routes.url_helpers.url_for(
      resource.send(attribute).variant(options).processed
    )
  rescue => e
    Rails.logger.warn("ActiveStorageField#variant_url fallback to original after #{e.class}: #{e.message}")

    Rails.application.routes.url_helpers.url_for(resource.send(attribute))
  end

  def attachable?
    resource.send(attribute).attached?
  end
end
