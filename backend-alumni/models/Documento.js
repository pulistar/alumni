module.exports = (sequelize, DataTypes) => {
  return sequelize.define('Documento', {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4
    },
    egresado_id: {
      type: DataTypes.UUID,
      allowNull: false
    },
    tipo: {
      type: DataTypes.STRING,
      allowNull: false
    },
    url: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    fecha_subida: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'documentos',
    timestamps: false
  });
};
