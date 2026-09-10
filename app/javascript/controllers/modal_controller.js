import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  open(event) {
    event.preventDefault();
    const id = this.element.dataset.modalId;
    const modal = document.getElementById(id);

    modal.classList.remove("hidden")
  }

  close(event){
    event.preventDefault();
    // Try data-modal-id first
    let modal;
    const id = this.element.dataset.modalId;
    if (id) {
      modal = document.getElementById(id);
    }

    // Fallback: nearest .modal wrapper
    if (!modal) {
      modal = this.element.closest('.modal');
    }

    if (modal) {
      modal.classList.add("hidden");
    }
  }
}