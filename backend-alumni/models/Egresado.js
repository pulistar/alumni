module.exports = (sequelize, DataTypes) => {
  return sequelize.define('Egresado', {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4
    },
    nombre: {
      type: DataTypes.STRING,
      allowNull: false
    },
    correo: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    carrera: {
      type: DataTypes.STRING,
      allowNull: false
    },
    password: {              // <-- Aquí agregas el campo password
      type: DataTypes.STRING,
      allowNull: false
    },
    habilitado: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    documentos_subidos: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    evaluacion_completada: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    fecha_registro: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'egresados',
    timestamps: false
  });
};
