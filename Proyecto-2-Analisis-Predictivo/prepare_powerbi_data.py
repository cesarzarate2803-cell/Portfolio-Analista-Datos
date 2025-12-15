"""
=============================================================================
PREPARACIÓN DE DATOS PARA POWER BI - DATASET COMPLETO
Combinar dataset original con predicciones del modelo ML
=============================================================================
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
import warnings
warnings.filterwarnings('ignore')

print("="*80)
print("PREPARANDO DATOS COMPLETOS PARA POWER BI")
print("="*80)

# =============================================================================
# PASO 1: CARGAR DATASET ORIGINAL COMPLETO
# =============================================================================

print("\n[1/5] Cargando dataset original completo...")
df_original = pd.read_excel('data/HR-Employee-Attrition.xlsx')
df_original.columns = df_original.columns.str.strip()
print(f" Dataset cargado: {len(df_original)} registros")

# =============================================================================
# PASO 2: PREPARAR DATOS PARA MODELO ML
# =============================================================================

print("\n[2/5] Preparando datos para modelo ML...")

# Crear copia para ML
df_ml = df_original.copy()

# Convertir Deserción a numérico
df_ml['Desercion_Num'] = df_ml['Deserción'].map({'No': 0, 'Yes': 1})

# Columnas a eliminar
cols_to_drop = ['Número de empleados', 'Número de empleados.1', 'Más de 18 horas extra', 'Horas estándar']

# Codificar variables categóricas
categorical_cols = df_ml.select_dtypes(include=['object']).columns.tolist()
categorical_cols = [col for col in categorical_cols if col not in cols_to_drop + ['Deserción']]

label_encoders = {}
for col in categorical_cols:
    le = LabelEncoder()
    df_ml[col + '_Encoded'] = le.fit_transform(df_ml[col])
    label_encoders[col] = le

# Preparar features (X) y target (y)
feature_cols = [col for col in df_ml.columns if col.endswith('_Encoded')] + \
               [col for col in df_ml.select_dtypes(include=[np.number]).columns 
                if col not in cols_to_drop + ['Desercion_Num']]

X = df_ml[feature_cols]
y = df_ml['Desercion_Num']

print(f"   Features para el modelo: {len(feature_cols)}")

# =============================================================================
# PASO 3: ENTRENAR MODELO CON TODOS LOS DATOS
# =============================================================================

print("\n[3/5] Entrenando modelo con todos los datos...")

model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    min_samples_split=10,
    random_state=42,
    n_jobs=-1
)

model.fit(X, y)
print(" Modelo entrenado")

# Hacer predicciones para TODOS los empleados
predictions = model.predict(X)
probabilities = model.predict_proba(X)[:, 1]

print(f"   Predicciones generadas: {len(predictions)}")

# =============================================================================
# PASO 4: CREAR DATASET COMPLETO PARA POWER BI
# =============================================================================

print("\n[4/5] Creando dataset para Power BI...")

# Empezar con el dataset original
df_powerbi = df_original.copy()

# Agregar predicciones del modelo
df_powerbi['Prediccion_ML'] = pd.Series(predictions).map({0: 'No', 1: 'Yes'})
df_powerbi['Probabilidad_Desercion'] = probabilities

# Crear categoría de riesgo
df_powerbi['Riesgo_ML'] = pd.cut(
    probabilities, 
    bins=[0, 0.3, 0.6, 1.0], 
    labels=['Bajo', 'Medio', 'Alto'],
    include_lowest=True
)

# Validar que no haya valores nulos en Riesgo_ML
if df_powerbi['Riesgo_ML'].isnull().any():
    df_powerbi['Riesgo_ML'].fillna('Medio', inplace=True)

print(f"   Distribución de Riesgo_ML:")
print(f"   {df_powerbi['Riesgo_ML'].value_counts()}")

# Crear categorías adicionales
df_powerbi['Grupo_Edad'] = pd.cut(
    df_powerbi['Edad'], 
    bins=[0, 30, 40, 50, 100], 
    labels=['<30', '30-40', '40-50', '50+']
)

df_powerbi['Rango_Salario'] = pd.cut(
    df_powerbi['Ingresos mensuales'], 
    bins=[0, 3000, 6000, 10000, 20000], 
    labels=['<3K', '3K-6K', '6K-10K', '10K+']
)

df_powerbi['Distancia_Categoria'] = pd.cut(
    df_powerbi['Distancia desde casa'], 
    bins=[0, 5, 10, 20, 30], 
    labels=['Cerca <5km', 'Media 5-10km', 'Lejos 10-20km', 'Muy lejos >20km']
)

# Mapear valores numéricos a texto descriptivo
mappings = {
    'Educación': {1: 'Below College', 2: 'College', 3: 'Bachelor', 4: 'Master', 5: 'Doctor'},
    'Satisfacción con el entorno': {1: 'Bajo', 2: 'Medio', 3: 'Alto', 4: 'Muy Alto'},
    'Participación en el trabajo': {1: 'Bajo', 2: 'Medio', 3: 'Alto', 4: 'Muy Alto'},
    'Satisfacción laboral': {1: 'Bajo', 2: 'Medio', 3: 'Alto', 4: 'Muy Alto'},
    'Calificación del rendimiento': {1: 'Bajo', 2: 'Bueno', 3: 'Excelente', 4: 'Sobresaliente'},
    'Satisfacción de la relación': {1: 'Bajo', 2: 'Medio', 3: 'Alto', 4: 'Muy Alto'},
    'Balance de vida laboral': {1: 'Malo', 2: 'Bueno', 3: 'Mejor', 4: 'Óptimo'}
}

for col, mapping in mappings.items():
    df_powerbi[f'{col}_Texto'] = df_powerbi[col].map(mapping)

# Crear indicador de coincidencia (Predicción correcta)
df_powerbi['Prediccion_Correcta'] = (df_powerbi['Deserción'] == df_powerbi['Prediccion_ML']).map({True: 'Correcto', False: 'Incorrecto'})

print(f" Dataset completo creado: {len(df_powerbi)} registros")
print(f"   Columnas totales: {len(df_powerbi.columns)}")

# =============================================================================
# PASO 5: GUARDAR ARCHIVOS
# =============================================================================

print("\n[5/5] Guardando archivos para Power BI...")

# 1. Dataset principal
df_powerbi.to_excel('outputs/PowerBI_Dataset_Complete.xlsx', index=False)
print(f" Guardado: PowerBI_Dataset_Complete.xlsx ({len(df_powerbi)} registros)")

# 2. Feature Importance
feature_importance = pd.DataFrame({
    'Feature': feature_cols,
    'Importance': model.feature_importances_
}).sort_values('Importance', ascending=False)

# Limpiar nombres de features (quitar '_Encoded')
feature_importance['Feature'] = feature_importance['Feature'].str.replace('_Encoded', '')
feature_importance.to_excel('outputs/PowerBI_FeatureImportance.xlsx', index=False)
print(f" Guardado: PowerBI_FeatureImportance.xlsx")

# 3. Métricas del modelo
from sklearn.metrics import accuracy_score

accuracy = accuracy_score(y, predictions)
print(f"\n    Accuracy del modelo (train completo): {accuracy:.2%}")

model_metrics = pd.DataFrame({
    'Metrica': ['Accuracy', 'Total Empleados', 'Desercion Real', 'Desercion Predicha'],
    'Valor': [
        accuracy,
        len(df_powerbi),
        (df_powerbi['Deserción'] == 'Yes').sum(),
        (df_powerbi['Prediccion_ML'] == 'Yes').sum()
    ]
})
model_metrics.to_excel('outputs/PowerBI_ModelMetrics.xlsx', index=False)
print(f" Guardado: PowerBI_ModelMetrics.xlsx")

# 4. Tabla de empleados de alto riesgo
high_risk = df_powerbi[df_powerbi['Riesgo_ML'] == 'Alto'][
    ['Número de empleados.1', 'Edad', 'Departamento', 'Rol del puesto', 'Ingresos mensuales', 
     'Deserción', 'Probabilidad_Desercion', 'Riesgo_ML']
].sort_values('Probabilidad_Desercion', ascending=False)

high_risk.to_excel('outputs/PowerBI_HighRisk.xlsx', index=False)
print(f" Guardado: PowerBI_HighRisk.xlsx ({len(high_risk)} empleados)")

# =============================================================================
# RESUMEN
# =============================================================================

print("\n" + "="*80)
print(" PREPARACIÓN COMPLETADA - DATASET COMPLETO")
print("="*80)
print(f"\n ESTADÍSTICAS DEL DATASET:")
print(f"   • Total empleados: {len(df_powerbi)}")
print(f"   • Deserción real (Yes): {(df_powerbi['Deserción'] == 'Yes').sum()} ({(df_powerbi['Deserción'] == 'Yes').sum()/len(df_powerbi)*100:.1f}%)")
print(f"   • Predicción ML (Yes): {(df_powerbi['Prediccion_ML'] == 'Yes').sum()} ({(df_powerbi['Prediccion_ML'] == 'Yes').sum()/len(df_powerbi)*100:.1f}%)")
print(f"\n DISTRIBUCIÓN DE RIESGO ML:")
print(f"   • Bajo: {(df_powerbi['Riesgo_ML'] == 'Bajo').sum()} empleados")
print(f"   • Medio: {(df_powerbi['Riesgo_ML'] == 'Medio').sum()} empleados")
print(f"   • Alto: {(df_powerbi['Riesgo_ML'] == 'Alto').sum()} empleados")
print(f"\n ARCHIVOS GENERADOS:")
print(f"   1. PowerBI_Dataset_Complete.xlsx (archivo principal - USAR ESTE)")
print(f"   2. PowerBI_FeatureImportance.xlsx")
print(f"   3. PowerBI_ModelMetrics.xlsx")
print(f"   4. PowerBI_HighRisk.xlsx")
print(f"\n SIGUIENTE PASO:")
print(f"   1. Abre Power BI Desktop")
print(f"   2. Importa PowerBI_Dataset_Complete.xlsx")
print(f"   3. Crea el dashboard interactivo")
print("="*80)