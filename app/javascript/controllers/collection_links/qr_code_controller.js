import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    id: Number
  }

  connect() {
  }

  // Generate a QR code via Turbo request
  generate(event) {
    event.preventDefault()

    const container = document.getElementById(`qr-code-${this.idValue}-container`)

    // If QR code is already visible, hide it
    if (!container.classList.contains('hidden')) {
      this.hide(event)
      return
    }

    // Show loading state
    container.classList.remove('hidden')
    Turbo.visit(`/collection_links/${this.idValue}/qr_code`, { frame: `qr-code-${this.idValue}` })
  }

  // Hide the QR code container
  hide(event) {
    event.preventDefault()
    const container = document.getElementById(`qr-code-${this.idValue}-container`)
    container.classList.add('hidden')
  }
}