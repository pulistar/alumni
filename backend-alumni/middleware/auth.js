const jwt = require('jsonwebtoken');
const config = require('../config/config');

function authenticateToken(req, res, next) {
  // Leer token del header Authorization: Bearer <token>
  const authHeader = req.headers['authorization'];
  console.log('Auth Header:', authHeader);
  
  const token = authHeader && authHeader.split(' ')[1];
  console.log('Token:', token);
  
  if (!token) return res.status(401).json({ message: 'Token no proporcionado' });

  jwt.verify(token, config.jwt.secret, (err, user) => {
    if (err) {
      console.log('Error al verificar token:', err);
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ message: 'Token expirado' });
      }
      return res.status(401).json({ message: 'Token inválido' });
    }
    
    console.log('Usuario decodificado:', user);
    // Guardar info del usuario decodificada para usar en rutas
    req.user = user;
    next();
  });
}

module.exports = authenticateToken;
