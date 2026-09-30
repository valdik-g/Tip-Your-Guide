module ButtonHelper
  BASE_BUTTON_CLASSES = "inline-flex items-center justify-center font-semibold rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 disabled:cursor-not-allowed"

  SIZE_CLASSES = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-5 py-2.5 text-base",
    lg: "px-6 py-3 text-lg"
  }

  VARIANT_CLASSES = {
    primary: "text-white bg-indigo-600 hover:bg-black focus:bg-indigo-800 disabled:bg-gray-400 disabled:hover:bg-gray-400",
    secondary: "text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 focus:ring-gray-500 disabled:bg-gray-100",
    danger: "text-white bg-red-600 hover:bg-red-700 focus:ring-red-500 disabled:bg-gray-400",
    outline: "text-indigo-600 border border-indigo-600 hover:bg-indigo-50 focus:ring-indigo-500"
  }

  CTA_SIZE_CLASSES = "px-6 py-2.5 text-base"
  CTA_LAYOUT_CLASSES = "w-full sm:w-auto whitespace-normal break-words focus:ring-offset-2"
  CTA_VARIANT_CLASSES = {
    primary: "text-white bg-indigo-600 hover:bg-black focus:ring-indigo-500",
    secondary: "text-white bg-gray-600 hover:bg-black focus:ring-gray-500"
  }

  def button_classes(variant = :primary, size: :md)
    "#{BASE_BUTTON_CLASSES} #{SIZE_CLASSES[size]} #{VARIANT_CLASSES[variant]}"
  end

  def input_classes
    "px-4 py-4 w-full text-base text-gray-900 placeholder-gray-500 ring-1 ring-zinc-950/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-black bg-white [&:invalid]:text-gray-500 [&:invalid]:ring-red-500"
  end

  def cta_classes(variant = :primary, type: :button)
    type_classes = (type == :link) ? "no-underline" : "cursor-pointer"

    "#{BASE_BUTTON_CLASSES} #{CTA_SIZE_CLASSES} #{CTA_LAYOUT_CLASSES} " \
      "#{CTA_VARIANT_CLASSES[variant]} #{type_classes}"
  end
end
