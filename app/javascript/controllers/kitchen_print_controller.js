import { Controller } from "@hotwired/stimulus"
import { buildKitchenTicket } from "escpos_builder"
import { printRaw } from "qz_client"

// Busca os itens ainda não enviados à cozinha, imprime na térmica e só
// confirma como "enviado" no servidor depois que a impressão deu certo —
// assim um clique com o QZ Tray offline nunca perde nem duplica itens.
export default class extends Controller {
  static values = { ticketUrl: String, confirmUrl: String, printerName: String }
  static targets = ["status", "button"]

  async send(event) {
    event.preventDefault()
    this.buttonTarget.disabled = true
    this.setStatus("Enviando para a cozinha...")

    try {
      const response = await fetch(this.ticketUrlValue, { headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error("Não foi possível buscar os itens pendentes.")
      const data = await response.json()

      if (data.items.length === 0) {
        this.setStatus("Nenhum item novo para enviar.")
        return
      }

      await printRaw(this.printerNameValue, buildKitchenTicket(data))

      await fetch(this.confirmUrlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": this.csrfToken },
        body: JSON.stringify({ order_item_ids: data.items.map((item) => item.id) }),
      })

      const count = data.items.length
      this.setStatus(`Enviado${count > 1 ? "s" : ""}: ${count} ite${count > 1 ? "ns" : "m"}.`)
    } catch (error) {
      this.setStatus(error.message || "Erro ao imprimir. Tente novamente.")
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
}
