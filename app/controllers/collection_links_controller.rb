class CollectionLinksController < ApplicationController
  skip_before_action :require_authentication, only: [:show]

  after_action :save_view, only: [:show]

  def index
    @collections = if current_user.is_admin?
      Collection.includes(:user, :collection_links).order(id: :asc)
    else
      current_user.collections.includes(:collection_links).order(id: :asc)
    end
  end

  def show
    @collection_link = CollectionLink.find_by!(link: params[:id])
    @collection = @collection_link.collection
    @places = @collection_link.collection.places.includes(:google_place)

    render "collections/show"
  end

  def qr_code
    @link = CollectionLink.find(params[:id])
    @qr_code = RQRCode::QRCode.new(@link.collection_link_url).as_svg(
      use_path: true,
      viewbox: true,
      shape_rendering: "crispEdges"
    )

    render(CollectionLinks::QrCodeComponent.new(link: @link, qr_code: @qr_code), content_type: "text/html")
  end

  private

  def save_view
    @collection_link.save_view!
  end
end
