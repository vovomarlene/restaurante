import { Controller } from "@hotwired/stimulus"

// Mostra o seletor de cliente só quando a forma de pagamento é "Fiado".
export default class extends Controller {
  static targets = ["customerField"]

  toggle(event) {
    this.customerFieldTarget.classList.toggle("hidden", event.target.value !== "fiado")
  }
}
