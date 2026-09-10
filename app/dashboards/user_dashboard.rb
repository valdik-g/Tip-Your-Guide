require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    slug: Field::String,
    email: Field::String,
    full_name: Field::String,
    city: Field::String,
    country: Field::Select.with_options(collection: ISO3166::Country.translations.invert),
    password: Field::Password,
    bio: Field::RichText,
    roles: Field::HasMany,
    role: RoleField,
    avatar: ActiveStorageField,
    sessions: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    interests: StringArrayField,
    guide_link: GuideLinkField,
    masquerade_link: MasqueradeLinkField,
    collections_enabled: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    full_name
    email
    slug
    role
    collections_enabled
    guide_link
    masquerade_link
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    full_name
    email
    slug
    city
    country
    avatar
    bio
    interests
    collections_enabled
    role
    sessions
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    full_name
    email
    password
    slug
    collections_enabled
    country
    city
    avatar
    bio
    roles
    interests
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

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end

  def display_resource(user)
    user.full_name
  end
end
