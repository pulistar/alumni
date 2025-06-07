const config = require('../config/config');

function csrfProtection(req, res, next) {
  // En desarrollo, permitir todas las peticiones
  if (config.env === 'development') {
    return next();
  }

  // Solo verificar CSRF en métodos que modifican datos
  if (['POST', 'PUT', 'DELETE'].includes(req.method)) {
    const csrfToken = req.headers['x-csrf-token'];
    
    if (!csrfToken) {
      return res.status(403).json({ message: 'Token CSRF requerido' });
    }

    // En un entorno real, verificaríamos el token contra uno almacenado en sesión
    // Por ahora, solo verificamos que el token coincida con el secreto
    if (csrfToken !== config.csrf.secret) {
      return res.status(403).json({ message: 'Token CSRF inválido' });
    }
  }

  next();
}

module.exports = csrfProtection; 