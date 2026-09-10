import { Application } from "@hotwired/stimulus"
import QrCodeController from 'controllers/collection_links/qr_code_controller'
import ClipboardController from "controllers/clipboard_controller"
import TruncatedTextController from "controllers/truncated_text_controller"
import AgenciesDashboardController from "controllers/agencies/dashboard_controller"
import ModalController from "controllers/modal_controller"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application


Stimulus.register("qr-code", QrCodeController)
Stimulus.register("clipboard", ClipboardController)
Stimulus.register("truncated-text", TruncatedTextController)
Stimulus.register("agency-dashboard", AgenciesDashboardController)
Stimulus.register("modal", ModalController)

export { application }
