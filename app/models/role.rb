class Role < ApplicationRecord
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users, join_table: :users_roles
  # rubocop:enable Rails/HasAndBelongsToMany

  validates :resource_type, inclusion: {in: Rolify.resource_types}, allow_nil: true
  belongs_to :resource, polymorphic: true, optional: true

  scopify

  def self.guide
    find_or_create_by(name: "guide")
  end

  def self.admin
    find_or_create_by(name: "admin")
  end
end
