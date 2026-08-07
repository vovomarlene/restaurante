import { Controller } from "@hotwired/stimulus"
import { buildReceiptTicket } from "escpos_builder"
import { printRaw } from "qz_client"

export default class extends Controller {
  static values = { url: String, printerName: String }
  static targets = ["status", "button"]

  async print(event) {
    event.preventDefault()
    this.buttonTarget.disabled = true
    this.setStatus("Imprimindo...")

    try {
      const response = await fetch(this.urlValue, { headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error("Não foi possível carregar o recibo.")
      const data = await response.json()

      await printRaw(this.printerNameValue, buildReceiptTicket(data))
      this.setStatus("Impresso.")
    } catch (error) {
      this.setStatus(error.message || "Erro ao imprimir. Tente novamente.")
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }
}
