const config = require('../config/config');

const validation = {
  // Validación de correo electrónico
  validateEmail: (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email) && email.endsWith(config.security.allowedEmailDomain);
  },

  // Validación de contraseña
  validatePassword: (password) => {
    const minLength = config.security.passwordMinLength;
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
    
    return password.length >= minLength && 
           hasUpperCase && 
           hasLowerCase && 
           hasNumbers && 
           hasSpecialChar;
  },

  // Sanitización de inputs
  sanitizeInput: (input) => {
    if (typeof input !== 'string') return input;
    return input.replace(/[<>]/g, '').trim();
  },

  // Middleware de validación de registro
  validateRegister: (req, res, next) => {
    const { nombre, correo, carrera, password } = req.body;

    if (!nombre || !correo || !carrera || !password) {
      return res.status(400).json({ 
        message: 'Todos los campos son obligatorios.' 
      });
    }

    if (!validation.validateEmail(correo)) {
      return res.status(400).json({ 
        message: `El correo debe ser válido y terminar en ${config.security.allowedEmailDomain}` 
      });
    }

    if (!validation.validatePassword(password)) {
      return res.status(400).json({ 
        message: 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial' 
      });
    }

    // Sanitizar todos los inputs
    Object.keys(req.body).forEach(key => {
      req.body[key] = validation.sanitizeInput(req.body[key]);
    });

    next();
  },

  // Middleware de validación de login
  validateLogin: (req, res, next) => {
    const { correo, password } = req.body;

    if (!correo || !password) {
      return res.status(400).json({ 
        message: 'Correo y contraseña son obligatorios.' 
      });
    }

    if (!validation.validateEmail(correo)) {
      return res.status(400).json({ 
        message: `El correo debe ser válido y terminar en ${config.security.allowedEmailDomain}` 
      });
    }

    next();
  }
};

module.exports = validation; 