import { Controller } from "@hotwired/stimulus"
import { findPrinters } from "qz_client"

export default class extends Controller {
  static targets = ["list", "status", "receiptInput", "kitchenInput", "suggestions"]

  async detect(event) {
    event.preventDefault()
    this.setStatus("Procurando impressoras...")

    try {
      const printers = await findPrinters()
      this.listTarget.replaceChildren(
        ...printers.map((name) => {
          const option = document.createElement("option")
          option.value = name
          return option
        })
      )

      if (printers.length === 0) {
        this.setStatus("Nenhuma impressora encontrada. Preencha manualmente.")
      } else if (printers.length === 1) {
        // Caso mais comum: uma impressora só, usada pra recibo e cozinha.
        this.receiptInputTarget.value = printers[0]
        this.kitchenInputTarget.value = printers[0]
        this.setStatus(`Impressora "${printers[0]}" preenchida nos dois campos. Clique em Salvar.`)
      } else {
        this.renderSuggestions(printers)
        this.setStatus(`${printers.length} impressoras encontradas — clique em uma abaixo para preencher o campo.`)
      }
    } catch (error) {
      this.setStatus(error.message || "Não foi possível detectar. Preencha manualmente.")
    }
  }

  renderSuggestions(printers) {
    this.suggestionsTarget.replaceChildren(
      ...printers.map((name) => {
        const wrapper = document.createElement("div")
        wrapper.className = "flex items-center gap-2 text-sm"

        const label = document.createElement("span")
        label.textContent = name
        label.className = "font-medium"

        const receiptButton = this.suggestionButton(`Usar no recibo`, () => { this.receiptInputTarget.value = name })
        const kitchenButton = this.suggestionButton(`Usar na cozinha`, () => { this.kitchenInputTarget.value = name })

        wrapper.append(label, receiptButton, kitchenButton)
        return wrapper
      })
    )
  }

  suggestionButton(text, onClick) {
    const button = document.createElement("button")
    button.type = "button"
    button.textContent = text
    button.className = "px-2 py-0.5 rounded border border-gray-300 hover:bg-surface-muted text-xs cursor-pointer"
    button.addEventListener("click", onClick)
    return button
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }
}
