import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.deadline = this.parseDeadline()

    if (!this.deadline) {
      this.element.textContent = "Unavailable"
      return
    }

    this.render()
    this.interval = window.setInterval(() => this.render(), 1000)
  }

  disconnect() {
    if (this.interval) window.clearInterval(this.interval)
  }

  parseDeadline() {
    const rawDeadline = this.element.dataset.deadlineAt
    if (!rawDeadline) return null

    const deadline = new Date(rawDeadline)
    if (Number.isNaN(deadline.getTime())) return null

    return deadline
  }

  render() {
    const remainingSeconds = Math.ceil((this.deadline.getTime() - Date.now()) / 1000)

    if (remainingSeconds <= 0) {
      this.element.textContent = "Expired"
      window.clearInterval(this.interval)
      return
    }

    this.element.textContent = this.formatRemaining(remainingSeconds)
  }

  formatRemaining(remainingSeconds) {
    if (remainingSeconds < 60) return "Less than 1 minute"

    const days = Math.floor(remainingSeconds / 86400)
    const hours = Math.floor((remainingSeconds % 86400) / 3600)
    const minutes = Math.floor((remainingSeconds % 3600) / 60)

    return [
      days > 0 ? `${days}d` : null,
      hours > 0 ? `${hours}h` : null,
      minutes > 0 ? `${minutes}m` : null
    ].filter(Boolean).join(" ")
  }
}
