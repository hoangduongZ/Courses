const BLOCK_THRESHOLD = 3
const BLOCK_DURATION_MS = 60 * 60 * 1000
const blockedIPs = new Map()

async function login(email, password, ip) {
  if (blockedIPs.has(ip)) {
    logger.warn(`[AuthService] Blocked IP attempted login: ${ip}`)
    throw new Error('IP blocked due to brute force detection')
  }
  const user = await db.users.findByEmail(email)
  if (!user || !verifyPassword(password, user.passwordHash)) {
    trackFailedAttempt(ip)
    logger.error(`[AuthService] Failed login for ${email} (IP: ${ip})`)
    throw new Error('Invalid credentials')
  }
  logger.info(`[AuthService] User ${email} logged in`)
  return generateToken(user)
}

function trackFailedAttempt(ip) {
  const attempts = (blockedIPs.get(ip) || 0) + 1
  if (attempts >= BLOCK_THRESHOLD) {
    logger.warn(`[AuthService] Brute force from IP: ${ip} — blocked 1h`)
    setTimeout(() => blockedIPs.delete(ip), BLOCK_DURATION_MS)
  }
  blockedIPs.set(ip, attempts)
}

module.exports = { login }
