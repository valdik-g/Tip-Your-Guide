// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "trix"
import "@rails/actiontext"


// Add this to ensure styles are applied after Turbo Frame loads
document.addEventListener('turbo:frame-load', (event) => {
  // Force a browser reflow to ensure styles are applied correctly
  const frame = event.target;

  // Get the computed styles of the frame to make Tailwind work
  window.getComputedStyle(frame);

  // Optional: Add a class to the loaded frame for more specific styling
  frame.classList.add('turbo-loaded');

  // Force a reflow
  void frame.offsetHeight;
});
