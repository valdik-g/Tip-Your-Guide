require "administrate/base_dashboard"
class Collection
  class PriceDashboard < Administrate::BaseDashboard
    ATTRIBUTE_TYPES = {
      id: Field::Number,
      price: Field::Number,
      currency: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys })
    }

    FORM_ATTRIBUTES = %i[
      price
      currency
    ]
  end
end
