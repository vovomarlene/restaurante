module ApplicationHelper
  include Pagy::Frontend

  def active_badge(active)
    if active
      content_tag(:span, "Sim", class: "px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800")
    else
      content_tag(:span, "Não", class: "px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-600")
    end
  end
end
