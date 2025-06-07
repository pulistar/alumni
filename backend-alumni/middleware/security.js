const rateLimit = require('express-rate-limit');
const helmet = require('helmet');

// Rate limiter para login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // 5 intentos
  message: {
    message: 'Demasiados intentos de login. Por favor intente nuevamente en 15 minutos.'
  }
});

// Rate limiter general
const generalLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minuto
  max: 100 // 100 peticiones por minuto
});

// Configuración de Helmet
const helmetConfig = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"]
    }
  },
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: true,
  crossOriginResourcePolicy: { policy: "same-site" },
  dnsPrefetchControl: true,
  frameguard: { action: "deny" },
  hidePoweredBy: true,
  hsts: true,
  ieNoOpen: true,
  noSniff: true,
  referrerPolicy: { policy: "strict-origin-when-cross-origin" }
});

module.exports = {
  loginLimiter,
  generalLimiter,
  helmetConfig
}; 