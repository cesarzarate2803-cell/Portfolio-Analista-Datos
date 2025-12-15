"""
=============================================================================
PROYECTO 2 - PARTE 3: MACHINE LEARNING
Modelo Predictivo de Rotación de Empleados
=============================================================================
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, roc_auc_score, roc_curve
from sklearn.preprocessing import LabelEncoder
import warnings
warnings.filterwarnings('ignore')

print("="*80)
print("MODELO PREDICTIVO DE DESERCIÓN - MACHINE LEARNING")
print("="*80)

# =============================================================================
# PASO 1: CARGAR Y PREPARAR DATOS
# =============================================================================

print("\n[1/6] Cargando y preparando datos...")

# Cargar dataset
df = pd.read_excel('data/HR-Employee-Attrition.xlsx')
df.columns = df.columns.str.strip()  # Limpiar nombres
print(f" Dataset cargado: {len(df)} registros")

# Crear copia para no modificar original
df_ml = df.copy()

# Convertir variable objetivo a numérico
df_ml['Deserción'] = df_ml['Deserción'].map({'No': 0, 'Yes': 1})

print(f"   Distribución objetivo:")
print(f"   - No (0): {(df_ml['Deserción'] == 0).sum()} empleados ({(df_ml['Deserción'] == 0).sum()/len(df_ml)*100:.1f}%)")
print(f"   - Yes (1): {(df_ml['Deserción'] == 1).sum()} empleados ({(df_ml['Deserción'] == 1).sum()/len(df_ml)*100:.1f}%)")

# =============================================================================
# PASO 2: CODIFICAR VARIABLES CATEGORICAS
# =============================================================================

print("\n[2/6] Codificando variables categoricas...")

# Identificar columnas categóricas
categorical_cols = df_ml.select_dtypes(include=['object']).columns.tolist()

# Remover columnas que no se usarán en el modelo
cols_to_drop = ['Número de empleados', 'Número de empleados.1', 'Más de 18 horas extra', 'Horas estándar']
categorical_cols = [col for col in categorical_cols if col not in cols_to_drop]

print(f"   Variables categóricas a codificar: {len(categorical_cols)}")

# Crear LabelEncoder para cada columna categórica
label_encoders = {}
for col in categorical_cols:
    le = LabelEncoder()
    df_ml[col] = le.fit_transform(df_ml[col])
    label_encoders[col] = le

print(f"    {len(categorical_cols)} variables codificadas")

# Eliminar columnas innecesarias
df_ml = df_ml.drop(columns=cols_to_drop, errors='ignore')

print(f"   Variables finales para el modelo: {df_ml.shape[1] - 1}")

# =============================================================================
# PASO 3: DIVIDIR DATOS EN ENTRENAMIENTO Y PRUEBA
# =============================================================================

print("\n[3/6] Dividiendo datos en entrenamiento y prueba...")

# Separar features (X) y objetivo (y)
X = df_ml.drop('Deserción', axis=1)
y = df_ml['Deserción']

# Dividir en train (80%) y test (20%)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

print(f"    Datos divididos:")
print(f"      - Entrenamiento: {len(X_train)} registros ({len(X_train)/len(X)*100:.1f}%)")
print(f"      - Prueba: {len(X_test)} registros ({len(X_test)/len(X)*100:.1f}%)")
print(f"      - Features (variables): {X_train.shape[1]}")

# =============================================================================
# PASO 4: ENTRENAR MODELO RANDOM FOREST
# =============================================================================

print("\n[4/6] Entrenando modelo Random Forest...")

# Crear y entrenar modelo
model = RandomForestClassifier(
    n_estimators=100,      # Número de árboles
    max_depth=10,          # Profundidad máxima
    min_samples_split=10,  # Mínimo de muestras para dividir
    random_state=42,
    n_jobs=-1              # Usar todos los procesadores
)

model.fit(X_train, y_train)

print(f"    Modelo entrenado exitosamente")
print(f"      - Algoritmo: Random Forest")
print(f"      - Árboles: {model.n_estimators}")
print(f"      - Profundidad: {model.max_depth}")

# =============================================================================
# PASO 5: EVALUAR MODELO
# =============================================================================

print("\n[5/6] Evaluando desempeño del modelo...")

# Hacer predicciones
y_pred = model.predict(X_test)
y_pred_proba = model.predict_proba(X_test)[:, 1]

# Calcular métricas
accuracy = accuracy_score(y_test, y_pred)
roc_auc = roc_auc_score(y_test, y_pred_proba)

print(f"\n    MÉTRICAS DE DESEMPEÑO:")
print(f"   {'='*60}")
print(f"   Accuracy (Precisión): {accuracy:.2%}")
print(f"   ROC-AUC Score: {roc_auc:.2f}")
print(f"   {'='*60}")

# Reporte de clasificación detallado
print("\n    REPORTE DETALLADO:")
print(f"   {'='*60}")
print(classification_report(y_test, y_pred, target_names=['No Deserción', 'Deserción']))

# Matriz de confusión
cm = confusion_matrix(y_test, y_pred)
print(f"\n    MATRIZ DE CONFUSIÓN:")
print(f"   {'='*60}")
print(f"                Predicho No    Predicho Yes")
print(f"   Real No         {cm[0,0]:5d}         {cm[0,1]:5d}")
print(f"   Real Yes        {cm[1,0]:5d}         {cm[1,1]:5d}")
print(f"   {'='*60}")

# Interpretación
tn, fp, fn, tp = cm.ravel()
print(f"\n    INTERPRETACIÓN:")
print(f"   • Verdaderos Negativos (TN): {tn} - Predijo 'No' correctamente")
print(f"   • Falsos Positivos (FP): {fp} - Predijo 'Yes' pero era 'No'")
print(f"   • Falsos Negativos (FN): {fn} - Predijo 'No' pero era 'Yes'")
print(f"   • Verdaderos Positivos (TP): {tp} - Predijo 'Yes' correctamente")

# =============================================================================
# PASO 6: FEATURE IMPORTANCE (VARIABLES MÁS IMPORTANTES)
# =============================================================================

print("\n[6/6] Identificando variables más importantes...")

# Obtener importancia de features
feature_importance = pd.DataFrame({
    'Feature': X.columns,
    'Importance': model.feature_importances_
}).sort_values('Importance', ascending=False)

print(f"\n    TOP 10 VARIABLES MÁS IMPORTANTES:")
print(f"   {'='*60}")
for idx, row in feature_importance.head(10).iterrows():
    print(f"   {row['Feature']:30s} {row['Importance']:.4f}")

# =============================================================================
# VISUALIZACIONES DEL MODELO
# =============================================================================

print("\n" + "="*80)
print("GENERANDO VISUALIZACIONES DEL MODELO...")
print("="*80)

# GRÁFICO 1: Matriz de Confusión
print("\n[1/3] Matriz de confusión...")
fig, ax = plt.subplots(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', cbar=False, 
            xticklabels=['No', 'Yes'], yticklabels=['No', 'Yes'], ax=ax)
ax.set_title('Matriz de Confusión', fontsize=14, fontweight='bold')
ax.set_xlabel('Predicción', fontsize=12)
ax.set_ylabel('Real', fontsize=12)
plt.tight_layout()
plt.savefig('outputs/09_confusion_matrix.png', dpi=300, bbox_inches='tight')
print("    Guardado: 09_confusion_matrix.png")
plt.close()

# GRÁFICO 2: Feature Importance
print("[2/3] Importancia de variables...")
fig, ax = plt.subplots(figsize=(12, 8))
top_features = feature_importance.head(15)
ax.barh(top_features['Feature'], top_features['Importance'], color='steelblue', edgecolor='black')
ax.set_xlabel('Importancia', fontsize=12)
ax.set_title('Top 15 Variables Más Importantes para Predecir Deserción', fontsize=14, fontweight='bold')
ax.invert_yaxis()
for i, v in enumerate(top_features['Importance']):
    ax.text(v + 0.002, i, f'{v:.4f}', va='center', fontweight='bold')
plt.tight_layout()
plt.savefig('outputs/10_feature_importance.png', dpi=300, bbox_inches='tight')
print("    Guardado: 10_feature_importance.png")
plt.close()

# GRÁFICO 3: Curva ROC
print("[3/3] Curva ROC...")
fpr, tpr, thresholds = roc_curve(y_test, y_pred_proba)
fig, ax = plt.subplots(figsize=(8, 6))
ax.plot(fpr, tpr, color='darkorange', lw=2, label=f'ROC curve (AUC = {roc_auc:.2f})')
ax.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--', label='Random Classifier')
ax.set_xlim([0.0, 1.0])
ax.set_ylim([0.0, 1.05])
ax.set_xlabel('False Positive Rate', fontsize=12)
ax.set_ylabel('True Positive Rate', fontsize=12)
ax.set_title('Curva ROC (Receiver Operating Characteristic)', fontsize=14, fontweight='bold')
ax.legend(loc="lower right")
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig('outputs/11_roc_curve.png', dpi=300, bbox_inches='tight')
print("    Guardado: 11_roc_curve.png")
plt.close()

# =============================================================================
# GUARDAR RESULTADOS
# =============================================================================

print("\n" + "="*80)
print("GUARDANDO RESULTADOS...")
print("="*80)

# Guardar feature importance completo
feature_importance.to_csv('outputs/feature_importance.csv', index=False)
print(" Guardado: feature_importance.csv")

# Crear DataFrame con predicciones
predictions_df = pd.DataFrame({
    'Real': y_test.values,
    'Prediccion': y_pred,
    'Probabilidad_Desercion': y_pred_proba
})
predictions_df.to_csv('outputs/predictions.csv', index=False)
print(" Guardado: predictions.csv")

# =============================================================================
# RESUMEN FINAL
# =============================================================================

print("\n" + "="*80)
print(" MODELO COMPLETADO EXITOSAMENTE")
print("="*80)
print(f"\n RESUMEN DEL MODELO:")
print(f"   • Precisión (Accuracy): {accuracy:.2%}")
print(f"   • ROC-AUC Score: {roc_auc:.2f}")
print(f"   • Empleados correctamente clasificados: {(y_test == y_pred).sum()}/{len(y_test)}")
print(f"\n ARCHIVOS GENERADOS:")
print(f"   • outputs/09_confusion_matrix.png")
print(f"   • outputs/10_feature_importance.png")
print(f"   • outputs/11_roc_curve.png")
print(f"   • outputs/feature_importance.csv")
print(f"   • outputs/predictions.csv")
print(f"\n PRÓXIMO PASO: Preparar datos para Power BI")
print("="*80)