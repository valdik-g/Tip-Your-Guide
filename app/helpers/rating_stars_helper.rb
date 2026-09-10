module RatingStarsHelper
  def rating_to_stars(container_classes: "")
    return unless rating

    tag.div(class: container_classes) do
      render_stars
    end
  end

  private

  def render_stars
    rating.floor
    [
      full_rating_stars,
      maybe_half_rating_star,
      empty_rating_stars
    ].join.html_safe
  end

  def full_stars
    rating.floor
  end

  def full_rating_stars
    full_stars.times.map do
      tag.svg xmlns: "http://www.w3.org/2000/svg", class: "h-4 w-4 text-yellow-400 fill-yellow-400", viewBox: "0 0 20 20" do
        tag.path d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
      end
    end.join.html_safe
  end

  def maybe_half_rating_star
    rating
    full_stars
    return nil if (rating - full_stars) < 0.5

    tag.svg xmlns: "http://www.w3.org/2000/svg", class: "h-4 w-4 text-yellow-400", viewBox: "0 0 20 20" do
      defs = tag.defs do
        tag.linearGradient id: "half-star-#{place.id}", x1: "0%", y1: "0%", x2: "100%", y2: "0%" do
          [
            tag.stop(offset: "50%", "stop-color": "#FBBF24"),
            tag.stop(offset: "50%", "stop-color": "#F3F4F6")
          ].join.html_safe
        end
      end

      defs.concat(
        tag.path(fill: "url(#half-star-#{place.id})", d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z")
      )
    end
  end

  def empty_rating_stars
    return nil if rating.nil?
    empty_stars = 5 - full_stars - (maybe_half_rating_star ? 1 : 0)
    empty_stars.times.map do
      tag.svg xmlns: "http://www.w3.org/2000/svg", class: "h-4 w-4 text-gray-300", viewBox: "0 0 20 20" do
        tag.path fill: "#D1D5DB", d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
      end
    end.join.html_safe
  end
end
