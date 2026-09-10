module.exports = {
  content: [
    './app/views/**/*.{erb,haml,html,slim}',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './app/components/**/*.{erb,rb}'
  ],
  safelist: [
    // Text colors with all variations
    { pattern: /^text-(blue|pink|gray|green)-(50|100|200|300|400|500|600|700|800|900)$/ },
    { pattern: /^bg-(blue|pink|gray|green)-(50|100|200|300|400|500|600|700|800|900)$/ },
    // Basic colors
    'text-black',
    'text-white',
    // Utility classes
    'inline-block',
    'inline-flex',
    'items-center',
    'justify-center',
    'rounded-full',
    'w-10',
    'h-10',
    'mr-1',
    'ml-1',
    'mb-1',
    'mt-1',
    'animate-spin',
    '-ml-1',
    'mr-3',
  ],
  theme: {
    extend: {
      keyframes: {
      },
      animation: {
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}