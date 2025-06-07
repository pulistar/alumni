module.exports = (sequelize, DataTypes) => {
  return sequelize.define('Evaluacion', {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4
    },
    egresado_id: {
      type: DataTypes.UUID,
      allowNull: false
    },
    empleo_actual: {
      type: DataTypes.STRING
    },
    relacionado_carrera: {
      type: DataTypes.BOOLEAN
    },
    competencias_utiles: {
      type: DataTypes.ARRAY(DataTypes.TEXT) // Array de strings
    },
    sugerencias: {
      type: DataTypes.TEXT
    },
    fecha: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'evaluaciones',
    timestamps: false
  });
};
