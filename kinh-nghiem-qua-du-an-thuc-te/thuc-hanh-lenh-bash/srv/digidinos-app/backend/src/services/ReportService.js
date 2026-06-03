const REPORT_OUTPUT_DIR = '/opt/backups/daily'

async function generateMonthlyRevenue(month, year) {
  logger.info(`[ReportService] Monthly revenue report requested`)
  try {
    const orders = await db.orders.findByMonth(month, year)
    const total = orders.reduce((sum, o) => sum + o.total, 0)
    const report = buildReport(orders, total)
    await fs.writeFile(`${REPORT_OUTPUT_DIR}/revenue_${year}${month}.txt`, report)
    return { total, count: orders.length }
  } catch (err) {
    logger.error(`[ReportService] Report failed: ${err.message}`)
    throw err
  }
}

module.exports = { generateMonthlyRevenue }
