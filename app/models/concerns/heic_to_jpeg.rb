module HeicToJpeg
  extend ActiveSupport::Concern

  SUPPORTED_HEIC_TYPES = %w[image/heic image/heif].freeze

  included do
    after_commit :convert_heic_attachments_to_jpeg, on: %i[create update]
  end

  class_methods do
    # Specify which attachment accessors should be processed.
    # Example: heic_convertible_for :avatar, :photo
    def heic_convertible_for(*attachment_names)
      @heic_attachment_names = attachment_names.map(&:to_sym)
    end

    def heic_attachment_names
      @heic_attachment_names || []
    end
  end

  private

  def convert_heic_attachments_to_jpeg
    self.class.heic_attachment_names.each do |name|
      attachment = public_send(name)
      next unless attachment.attached?
      next unless SUPPORTED_HEIC_TYPES.include?(attachment.blob.content_type)

      convert_and_replace(attachment)
    end
  end

  def convert_and_replace(attachment)
    require "image_processing/vips"

    # Open the binary on disk first – some versions of `image_processing` don't
    # recognise `ActiveStorage::Attached::*` objects directly.
    # Opening yields a Tempfile that `libvips` is happy with.
    attachment.open(tmpdir: Dir.tmpdir) do |file|
      processed = ImageProcessing::Vips
        .source(file)
        .convert("jpeg")
        .call

      File.open(processed.path) do |jpeg|
        attachment.attach(
          io: jpeg,
          filename: "#{attachment.filename.base}.jpg",
          content_type: "image/jpeg"
        )
      end
    ensure
      processed&.close!
    end
  rescue => e # rubocop:disable Style/RescueStandardError
    Rails.logger.warn("HeicToJpeg conversion failed for #{attachment.filename}: #{e.class} - #{e.message}")
  end
end
