const rateLimit = require('express-rate-limit');
const config = require('../config/config');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // 5 intentos
  message: { message: 'Demasiados intentos de inicio de sesión, intente más tarde' },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  loginLimiter
}; 