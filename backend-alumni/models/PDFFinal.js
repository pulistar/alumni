module.exports = (sequelize, DataTypes) => {
  return sequelize.define('PDFFinal', {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    egresado_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    url: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    fecha_generacion: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  }, {
    tableName: 'pdf_finales',
    timestamps: false,
  });
};
