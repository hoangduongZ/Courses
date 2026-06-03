const { createOrder, getOrder } = require('../services/OrderService')
const { processPayment } = require('../services/PaymentService')

async function createOrderHandler(req, res) {
  const { userId, items } = req.body
  const order = await createOrder(userId, items)
  await processPayment(order.id, order.total)
  logger.info(`[OrderService] Order #${order.id} created by user_id=${userId}`)
  res.status(201).json(order)
}

async function getOrderHandler(req, res) {
  const order = await getOrder(req.params.id)
  if (!order) return res.status(404).json({ error: 'Order not found' })
  res.json(order)
}

module.exports = { createOrderHandler, getOrderHandler }
