const { Sequelize, DataTypes } = require('sequelize');
require('dotenv').config();
const config = require('../config/config');

// Conexión a PostgreSQL
const sequelize = new Sequelize(
  config.db.database,
  config.db.username,
  config.db.password,
  {
    host: config.db.host,
    port: config.db.port,
    dialect: config.db.dialect,
    logging: config.db.logging,
    dialectOptions: config.db.dialectOptions
  }
);

// Función para verificar la conexión
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Conexión a PostgreSQL exitosa');
    return true;
  } catch (error) {
    console.error('❌ Error conectando a la base de datos:', error);
    return false;
  }
};

// Importar modelos
const Egresado = require('./egresado')(sequelize, DataTypes);
const Administrativo = require('./administrativo')(sequelize, DataTypes);
const Archivo = require('./archivo')(sequelize, DataTypes);
const Documento = require('./Documento')(sequelize, DataTypes);
const Evaluacion = require('./Evaluacion')(sequelize, DataTypes);

// Definir relaciones
Egresado.hasMany(Archivo);
Archivo.belongsTo(Egresado);

Egresado.hasMany(Documento);
Documento.belongsTo(Egresado);

Egresado.hasOne(Evaluacion, { foreignKey: 'egresado_id' });
Evaluacion.belongsTo(Egresado, { foreignKey: 'egresado_id' });

// Función para sincronizar modelos
const syncModels = async (force = false) => {
  try {
    await sequelize.sync({ force });
    console.log('✅ Modelos sincronizados correctamente');
    return true;
  } catch (error) {
    console.error('❌ Error sincronizando modelos:', error);
    return false;
  }
};

// Exportar modelos y conexión
module.exports = {
  sequelize,
  Egresado,
  Administrativo,
  Archivo,
  Documento,
  Evaluacion,
  testConnection,
  syncModels
};
