import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String
  }

  copy(event) {
    event.preventDefault()

    // Find the content element within the controller's element
    const contentElement = this.element.querySelector('.clipboard-content')
    if (!contentElement) return

    const originalContent = contentElement.innerHTML

    navigator.clipboard.writeText(this.textValue).then(
      () => {
        contentElement.innerHTML = `
          <span class="text-gray-600 mb-1">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="inline-block">
              <path d="M5 13l4 4L19 7" />
            </svg>
          </span>
          <span class="text-gray-600">
            Copied!
          </span>
        `

        // Reset after 2 seconds
        setTimeout(() => {
          contentElement.innerHTML = originalContent
        }, 2000)
      },
      () => {
        console.error('Failed to copy text')
      }
    )
  }
}