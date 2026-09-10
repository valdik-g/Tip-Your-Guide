class GuidesController < ApplicationController
  skip_before_action :require_authentication, only: [:show]

  def show
    @guide = User.find_by!(slug: params[:id])
    # TODO: add position field for ordering collections
    @collections = @guide.collections.published.with_rich_text_description.with_attached_thumbnail.eager_load(:paid_collection_links, {places: :google_place}, {collection_price: :payment_info}).order(created_at: :desc)
    @paid_links_per_collection = paid_links_per_collection
  end

  private

  def show_paid_links_for_free?
    current_user&.is_admin? || (current_user&.is_guide? && @guide.id == current_user&.id)
  end

  def paid_links_per_collection
    if show_paid_links_for_free?
      CollectionLink.paid_status.where(
        collection: @collections
      ).index_by(&:collection_id)
    else
      CollectionLink.paid_status.where(
        collection: @collections
      ).where(link: session[:purchased] || []).index_by(&:collection_id)
    end
  end
end
