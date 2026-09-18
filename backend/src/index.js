require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');

const { runMigrations } = require('./db/migrate');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const aiRoutes = require('./routes/ai');
const tripRoutes = require('./routes/trips');
const zoneRoutes = require('./routes/zones');
const geoRoutes = require('./routes/geo');
const hazardRoutes = require('./routes/hazards');
const billingRoutes = require('./routes/billing');
const seo = require('./seo');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
}));
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 250,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', (req, res, next) => {
  if (req.path.startsWith('/geo/tiles/')) return next();
  return limiter(req, res, next);
});

// Crawlable locale landings, robots.txt and sitemap.xml (before static / SPA).
seo.mount(app);

// Serve Flutter web app static files
const webBuildPath = path.join(__dirname, '..', 'public');
app.use(express.static(webBuildPath, {
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('manifest.json')) {
      res.setHeader('Content-Type', 'application/manifest+json');
      res.setHeader('Cache-Control', 'no-cache');
    }
    if (filePath.endsWith(`${path.sep}sw.js`) || filePath.endsWith('/sw.js')) {
      res.setHeader('Service-Worker-Allowed', '/');
      res.setHeader('Cache-Control', 'no-cache');
      res.setHeader('Content-Type', 'application/javascript');
    }
  },
}));

app.get('/api/status', (req, res) => {
  res.json({
    name: 'MilieuAlert API',
    version: '1.0.0',
    status: 'running',
    endpoints: [
      'POST /api/auth/register',
      'POST /api/auth/login',
      'GET /api/auth/me',
      'PUT /api/auth/me',
      'PATCH /api/auth/me',
      'GET /api/users/me',
      'PATCH /api/users/me',
      'GET /api/users/profile',
      'PUT /api/users/profile',
      'PATCH /api/users/profile',
      'GET /api/billing/catalog',
      'POST /api/billing/play',
      'POST /api/billing/redeem',
      'POST /api/ai/chat',
      'POST /api/ai/assist',
      'POST /api/ai/zone-check',
      'POST /api/trips/log',
      'GET /api/trips/history',
      'GET /api/zones/sync',
      'GET /api/zones/data',
      'GET /api/zones/coverage',
      'GET /api/geo/cameras',
      'POST /api/hazards/report',
      'GET /api/hazards/nearby',
      'POST /api/hazards/:id/vote',
      'GET /api/hazards/:id/comments',
      'POST /api/hazards/:id/comments',
      'GET /api/hazards/stream',
    ],
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/billing', billingRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/zones', zoneRoutes);
app.use('/api/geo', geoRoutes);
app.use('/api/hazards', hazardRoutes);

// SPA fallback - Flutter app at / and client routes. Locale + privacy stay on Express.
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api/')) return next();
  if (req.path === '/privacy' || req.path.startsWith('/privacy/')) return next();
  if (['/en', '/nl', '/it', '/robots.txt', '/sitemap.xml'].includes(req.path)) return next();
  res.sendFile(path.join(webBuildPath, 'index.html'));
});

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, '0.0.0.0', async () => {
  console.log(`MilieuAlert API running on port ${PORT}`);
  await runMigrations();
});
