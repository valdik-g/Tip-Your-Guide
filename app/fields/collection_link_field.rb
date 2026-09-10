require "administrate/field/base"

class CollectionLinkField < Administrate::Field::Base
  def to_s
    resource.collection_link_url(resource.link)
  end
end
