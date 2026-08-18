import { Controller } from "@hotwired/stimulus"

// Alterna qual categoria do cardápio aparece, sem recarregar a página —
// evita ter que rolar por um catálogo grande pra achar cada item.
export default class extends Controller {
  static targets = ["tab", "panel"]

  show(event) {
    const category = event.currentTarget.dataset.category

    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.category === category
      tab.classList.toggle("bg-primary-600", active)
      tab.classList.toggle("text-white", active)
      tab.classList.toggle("border-primary-600", active)
      tab.classList.toggle("bg-surface", !active)
      tab.classList.toggle("text-ink-muted", !active)
      tab.classList.toggle("border-gray-200", !active)
    })

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.category !== category)
    })
  }
}
