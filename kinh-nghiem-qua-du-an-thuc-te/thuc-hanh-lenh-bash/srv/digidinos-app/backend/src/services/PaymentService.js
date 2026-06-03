const MAX_RETRIES = 3
const GATEWAY_URL = 'https://payment.gateway.com/v2/charge'

async function processPayment(orderId, amount) {
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      const res = await fetch(GATEWAY_URL, { method: 'POST', body: JSON.stringify({ orderId, amount }) })
      if (res.ok) return await res.json()
    } catch (err) {
      logger.error(`[PaymentService] Retry failed for order #${orderId} (attempt ${attempt}/${MAX_RETRIES})`)
      if (attempt === MAX_RETRIES) throw err
    }
  }
}

module.exports = { processPayment }
