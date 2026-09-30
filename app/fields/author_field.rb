require "administrate/field/base"

class AuthorField < Administrate::Field::Base
  OTHER_AUTHOR_VALUE = "".freeze

  def self.permitted_attribute(attr, options = {})
    reflection = options[:resource_class].reflect_on_association(attr)

    (reflection&.foreign_key || "#{attr}_id").to_sym
  end

  def permitted_attribute
    self.class.permitted_attribute(attribute, resource_class: resource.class)
  end

  def select_options
    authors + [[I18n.t("administrate.fields.author_field.other_author"), OTHER_AUTHOR_VALUE]]
  end

  def selected_option
    data&.id || OTHER_AUTHOR_VALUE
  end

  def other_author_selected?
    data.nil?
  end

  def author_name
    resource.author_name
  end

  def other_author_value
    OTHER_AUTHOR_VALUE
  end

  private

  def authors
    User.order(:full_name).map { |author| [author.full_name, author.id] }
  end
end
