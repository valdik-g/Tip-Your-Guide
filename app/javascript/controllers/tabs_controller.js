import { Controller } from "@hotwired/stimulus"

// A simple tabs controller. It toggles visibility of panels and active state of their corresponding tabs.
// Usage example (ERB):
//   <div data-controller="tabs">
//     <button data-tabs-target="tab" data-action="tabs#change" data-tabs-id="first">Tab 1</button>
//     <button data-tabs-target="tab" data-action="tabs#change" data-tabs-id="second">Tab 2</button>
//     <div data-tabs-target="panel" data-tabs-id="first">...</div>
//     <div data-tabs-target="panel" data-tabs-id="second" class="hidden">...</div>
//   </div>
// The controller shows the first panel by default and switches when a tab is clicked.
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: String }

  connect() {
    // Determine initial active tab.
    const initial = this.activeValue || (this.tabTargets[0] && this.tabTargets[0].dataset.tabsId)
    if (initial) this.#show(initial)
  }

  change(event) {
    const id = event.currentTarget.dataset.tabsId
    this.#show(id)
  }

  #show(id) {
    // Toggle tab styles
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.tabsId === id
      tab.classList.toggle("border-b-2", isActive)
      tab.classList.toggle("border-green-500", isActive)
      tab.classList.toggle("font-medium", isActive)
      tab.classList.toggle("text-gray-900", isActive)
      tab.classList.toggle("text-gray-500", !isActive)
    })

    // Toggle panel visibility
    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.tabsId !== id)
    })
  }
}