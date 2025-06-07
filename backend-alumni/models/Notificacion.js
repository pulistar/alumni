module.exports = (sequelize, DataTypes) => {
  return sequelize.define('Notificacion', {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4
    },
    destinatario_id: {
      type: DataTypes.UUID,
      allowNull: false
    },
    tipo_destinatario: {
      type: DataTypes.STRING, // 'egresado' o 'administrativo'
      allowNull: false
    },
    titulo: {
      type: DataTypes.STRING,
      allowNull: false
    },
    mensaje: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    leida: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    fecha_envio: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'notificaciones',
    timestamps: false
  });
};
