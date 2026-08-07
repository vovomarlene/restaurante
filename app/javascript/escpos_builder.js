// Monta o array de strings com comandos ESC/POS crus que qz.print() espera.
// Bytes padrão, compatíveis com a maioria das térmicas 80mm não fiscais
// (Epson TM-T20, Elgin, Bematech etc). Se a sua impressora usar códigos
// diferentes para negrito/corte, ajuste as constantes abaixo.

const ESC = "\x1B"
const GS = "\x1D"

export const cmd = {
  init: ESC + "@",
  boldOn: ESC + "E" + "\x01",
  boldOff: ESC + "E" + "\x00",
  alignLeft: ESC + "a" + "\x00",
  alignCenter: ESC + "a" + "\x01",
  doubleOn: GS + "!" + "\x11",
  doubleOff: GS + "!" + "\x00",
  feed: "\x0A",
  cut: GS + "V" + "\x00",
}

const LINE_WIDTH = 42 // colunas aproximadas numa térmica 80mm em fonte padrão

// Distância entre o cabeçote de impressão e a lâmina de corte: sem avanço
// de papel suficiente antes do comando de corte, a impressora corta em cima
// das últimas linhas (ex: troco, agradecimento) antes delas saírem por
// completo. Se ainda cortar cedo demais na sua impressora, aumente este valor.
const FEED_LINES_BEFORE_CUT = 5

function feedBeforeCut() {
  return cmd.feed.repeat(FEED_LINES_BEFORE_CUT)
}

function line(left, right = "") {
  if (!right) return left + cmd.feed
  const spaces = Math.max(1, LINE_WIDTH - left.length - right.length)
  return left + " ".repeat(spaces) + right + cmd.feed
}

function separator() {
  return "-".repeat(LINE_WIDTH) + cmd.feed
}

// data: payload de OrdersController#receipt (format: :json)
export function buildReceiptTicket(data) {
  const out = [cmd.init, cmd.alignCenter, cmd.boldOn, data.restaurant_name + cmd.feed, cmd.boldOff]
  out.push(data.subtitle + cmd.feed, data.date_label + cmd.feed, cmd.alignLeft, separator())

  data.items.forEach((item) => {
    out.push(line(`${item.quantity}x ${item.product_name}`, item.total_price_label))
  })

  out.push(separator())
  out.push(line("Subtotal", data.subtotal_label))
  if (data.service_fee) {
    out.push(line(`Taxa de serviço (${data.service_fee.percent}%)`, data.service_fee.amount_label))
  }
  if (data.delivery_fee_label) {
    out.push(line("Taxa de entrega", data.delivery_fee_label))
  }
  out.push(cmd.boldOn, line("Total", data.total_label), cmd.boldOff)

  if (data.payments.length > 0) {
    out.push(separator())
    data.payments.forEach((payment) => {
      out.push(line(payment.method_label, payment.amount_label))
    })
  }

  out.push(cmd.feed, cmd.alignCenter, "Obrigado pela preferência!" + cmd.feed)
  out.push(feedBeforeCut(), cmd.cut)
  return out
}

// data: payload de OrdersController#kitchen_ticket (format: :json) — sem preços
export function buildKitchenTicket(data) {
  const out = [
    cmd.init, cmd.alignCenter, cmd.doubleOn, cmd.boldOn,
    data.subtitle + cmd.feed,
    cmd.doubleOff, cmd.boldOff,
    data.date_label + cmd.feed,
    cmd.alignLeft, separator(),
  ]

  data.items.forEach((item) => {
    out.push(cmd.boldOn, cmd.doubleOn, `${item.quantity}x ${item.product_name}` + cmd.feed, cmd.doubleOff, cmd.boldOff)
    if (item.notes) {
      out.push(`  obs: ${item.notes}` + cmd.feed)
    }
  })

  out.push(separator())
  out.push(feedBeforeCut(), cmd.cut)
  return out
}
