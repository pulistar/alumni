module.exports = (sequelize, DataTypes) => {
  return sequelize.define('Administrativo', {
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
    rol: {
      type: DataTypes.STRING,
      allowNull: false
    },
    hashed_password: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    fecha_registro: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'administrativos',
    timestamps: false
  });
};
