require "administrate/base_dashboard"

class CollectionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    collection_links: UserScopedHasManyField,
    collection_places: Field::HasMany,
    description: Field::RichText,
    places: UserScopedHasManyField,
    title: Field::String,
    thumbnail: ActiveStorageField,
    status: Field::Select.with_options(collection: Collection.statuses.keys),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    user: CurrentUserField,
    collection_price: Field::HasOne
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    user
    title
    collection_places
    status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    thumbnail
    title
    status
    description
    user
    collection_links
    places
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    title
    status
    thumbnail
    description
    places
    collection_price
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how collections are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(collection)
    collection.title.to_s
  end
end
