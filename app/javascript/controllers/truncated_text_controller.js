// app/javascript/controllers/truncated_text_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "overlay", "buttonContainer", "buttonText", "chevron"]
  static values = {
    maxHeight: Number,
    buttonShowMoreText: String,
    buttonShowLessText: String,
    expanded: { type: Boolean, default: false }
  }

  connect() {
    setTimeout(() => {
      this.checkOverflow();
    }, 10);

    // Re-check on window resize
    window.addEventListener('resize', this.checkOverflow.bind(this));
  }

  disconnect() {
    // Clean up event listener
    window.removeEventListener('resize', this.checkOverflow.bind(this));
  }

  checkOverflow() {
    // Compare scroll height to client height to detect overflow
    const content = this.contentTarget;
    const hasOverflow = content.scrollHeight > this.maxHeightValue;

    if (hasOverflow) {
      // Show overlay and button if content overflows
      this.overlayTarget.classList.add('opacity-100');
      this.buttonContainerTarget.style.display = 'block';
    } else {
      // Hide overlay and button if content fits
      this.overlayTarget.classList.remove('opacity-100');
      this.buttonContainerTarget.style.display = 'none';

      // Ensure content is at maximum height if there's no overflow
      if (!this.expandedValue) {
        content.style.maxHeight = `${this.maxHeightValue}px`;
      }
    }
  }

  toggle() {
    this.expandedValue = !this.expandedValue;

    const content = this.contentTarget;

    if (this.expandedValue) {
      // Expand to full height
      content.style.maxHeight = `${content.scrollHeight}px`;
      this.overlayTarget.classList.remove('opacity-100');
      this.overlayTarget.classList.add('opacity-0');
      this.buttonTextTarget.textContent = this.buttonShowLessTextValue;
      this.chevronTarget.style.transform = 'rotate(180deg)';
    } else {
      // Collapse to max height
      content.style.maxHeight = `${this.maxHeightValue}px`;
      this.overlayTarget.classList.remove('opacity-0');
      this.overlayTarget.classList.add('opacity-100');
      this.buttonTextTarget.textContent = this.buttonShowMoreTextValue;
      this.chevronTarget.style.transform = 'rotate(0)';
    }
  }
}