function requireBillingAdminKey(req, res, next) {
  const key = req.headers['x-billing-admin-key'] || req.body?.adminKey;
  if (!process.env.BILLING_ADMIN_KEY || key !== process.env.BILLING_ADMIN_KEY) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  return next();
}

module.exports = { requireBillingAdminKey };
