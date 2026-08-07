import { Controller } from "@hotwired/stimulus"

// Adiciona/remove linhas de formulário aninhado (ex: itens da ficha técnica).
// Uso: um container com data-nested-form-target="items", um <template>
// com data-nested-form-target="template" contendo NEW_RECORD como placeholder
// de índice, e cada linha marcada com data-nested-form-target="item".
export default class extends Controller {
  static targets = ["items", "template", "item"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.itemsTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const item = event.target.closest("[data-nested-form-target='item']")
    const destroyField = item.querySelector("input[name*='_destroy']")

    if (destroyField) {
      destroyField.value = "1"
      item.style.display = "none"
    } else {
      item.remove()
    }
  }
}
