const config = require('../config/config');

const handleError = (error, res) => {
  console.error('Error:', error);
  
  if (error.name === 'SequelizeValidationError') {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.errors.map(e => e.message)
    });
  }
  
  if (error.name === 'SequelizeUniqueConstraintError') {
    return res.status(409).json({
      message: 'El registro ya existe'
    });
  }
  
  res.status(500).json({
    message: 'Error interno del servidor',
    error: config.env === 'development' ? error.message : undefined
  });
};

module.exports = { handleError }; 