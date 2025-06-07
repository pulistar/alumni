require('dotenv').config();
const bcrypt = require('bcrypt');
const { Administrativo } = require('../models');
const config = require('../config/config');

const createInitialAdmin = async () => {
  try {
    // Verificar si ya existe un administrador
    const existingAdmin = await Administrativo.findOne({
      where: { correo: 'admin@campusucc.edu.co' }
    });

    if (existingAdmin) {
      console.log('✅ El administrador ya existe');
      process.exit(0);
    }

    // Crear el administrador inicial
    const hashedPassword = await bcrypt.hash('admin123', config.security.saltRounds);
    
    await Administrativo.create({
      nombre: 'Administrador',
      correo: 'admin@campusucc.edu.co',
      rol: 'admin',
      hashed_password: hashedPassword
    });

    console.log('✅ Administrador creado exitosamente');
    console.log('Correo: admin@campusucc.edu.co');
    console.log('Contraseña: admin123');
  } catch (error) {
    console.error('❌ Error creando administrador:', error);
  } finally {
    process.exit(0);
  }
};

createInitialAdmin(); 