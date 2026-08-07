// Ponte fina para o QZ Tray (window.qz, carregado via <script> clássico
// vendorizado em app/assets/vendor/qz-tray.js — não é ES module).
// Conexão sem certificado (modo não assinado): na primeira impressão o
// QZ Tray mostra um popup nativo pedindo permissão, com opção "lembrar".

export class QzUnavailableError extends Error {}

const CONNECT_TIMEOUT_MS = 5000

function withTimeout(promise, ms) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("timeout")), ms)
    promise.then(
      (value) => { clearTimeout(timer); resolve(value) },
      (error) => { clearTimeout(timer); reject(error) }
    )
  })
}

export async function ensureConnected() {
  if (typeof window.qz === "undefined") {
    throw new QzUnavailableError("Biblioteca do QZ Tray não carregou nesta página.")
  }

  if (window.qz.websocket.isActive()) return

  try {
    // Sem retries próprios: se o QZ Tray não responder rápido, preferimos
    // falhar em poucos segundos (com mensagem clara) a deixar o operador
    // esperando dezenas de segundos pelas tentativas internas da biblioteca.
    await withTimeout(window.qz.websocket.connect({ retries: 0 }), CONNECT_TIMEOUT_MS)
  } catch (error) {
    throw new QzUnavailableError("Não foi possível conectar ao QZ Tray. Verifique se ele está aberto no computador.")
  }
}

export async function printRaw(printerName, dataLines) {
  if (!printerName) {
    throw new QzUnavailableError("Nenhuma impressora configurada. Configure em Admin > Impressoras.")
  }

  await ensureConnected()

  const config = window.qz.configs.create(printerName)

  try {
    await window.qz.print(config, dataLines)
  } catch (error) {
    throw new QzUnavailableError(`Falha ao imprimir em "${printerName}". Confira o nome da impressora.`)
  }
}

export async function findPrinters() {
  await ensureConnected()
  return window.qz.printers.find()
}
