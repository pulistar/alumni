module.exports = (sequelize, DataTypes) => {
  return sequelize.define('Archivo', {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4
    },
    nombre: {
      type: DataTypes.STRING,
      allowNull: false
    },
    tipo: {
      type: DataTypes.STRING,
      allowNull: false
    },
    ruta: {
      type: DataTypes.STRING,
      allowNull: false
    },
    egresado_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'egresados',
        key: 'id'
      }
    },
    fecha_subida: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'archivos',
    timestamps: false
  });
}; 