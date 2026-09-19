module ButtonHelper
    def button_classes(variant = :primary, size: :md)
      base_classes = "inline-flex items-center justify-center font-semibold rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 disabled:cursor-not-allowed"
      
      size_classes = {
        sm: "px-3 py-1.5 text-sm",
        md: "px-5 py-2.5 text-base",
        lg: "px-6 py-3 text-lg"
      }
      
      variant_classes = {
        primary: "text-white bg-indigo-600 hover:bg-black focus:bg-indigo-800 disabled:bg-gray-400 disabled:hover:bg-gray-400",
        secondary: "text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 focus:ring-gray-500 disabled:bg-gray-100",
        danger: "text-white bg-red-600 hover:bg-red-700 focus:ring-red-500 disabled:bg-gray-400",
        outline: "text-indigo-600 border border-indigo-600 hover:bg-indigo-50 focus:ring-indigo-500"
      }
      
      "#{base_classes} #{size_classes[size]} #{variant_classes[variant]}"
    end
    
    def input_classes
      "px-4 py-4 w-full text-base text-gray-900 placeholder-gray-500 ring-1 ring-zinc-950/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-black bg-white [&:invalid]:text-gray-500 [&:invalid]:ring-red-500"
    end
  end