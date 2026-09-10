class CollectionsController < ApplicationController
  skip_before_action :require_authentication, only: [:show]

  def show
    @collection = Collection.find(params[:id])
    unless allowed_to_view?
      redirect_to guide_path(@collection.user.slug) and return
    end

    @places = @collection.places.includes(:google_place)

    render "collections/show"
  end

  private

  def allowed_to_view?
    return true if @collection.public_status?
    return true if @collection.user_id == current_user&.id
    return true if current_user&.admin?

    false
  end
end
