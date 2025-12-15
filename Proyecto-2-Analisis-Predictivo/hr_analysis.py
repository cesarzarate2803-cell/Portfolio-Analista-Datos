"""
=============================================================================
PROYECTO 2: ANÁLISIS PREDICTIVO DE ROTACIÓN DE EMPLEADOS
IBM HR Analytics Employee Attrition & Performance
=============================================================================
Autor: Cesar Jesus Zarate Pomaleque
Fecha: Diciembre 2025
Herramientas: Python, Pandas, Seaborn, Scikit-learn

PROYECTO 2 - PARTE 1: CARGA Y EXPLORACIÓN DE DATOS
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.preprocessing import LabelEncoder
import warnings
warnings.filterwarnings('ignore')

# Configuración de visualizaciones
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("husl")

print("="*80)
print("PROYECTO 2: ANÁLISIS DE ROTACIÓN DE EMPLEADOS (HR ANALYTICS)")
print("="*80)

# =============================================================================
# CARGA Y EXPLORACIÓN DE DATOS
# =============================================================================

print("\n[1/6] Cargando dataset...")

# Cargar datos
df = pd.read_excel('data/HR-Employee-Attrition.xlsx')

print(f" Dataset cargado exitosamente")
print(f"   Registros: {len(df)}")
print(f"   Columnas: {len(df.columns)}")

# Información básica
print("\n" + "="*80)
print("INFORMACIÓN DEL DATASET")
print("="*80)
print(df.info())

# Primeras filas
print("\n" + "="*80)
print("PRIMERAS 5 FILAS")
print("="*80)
print(df.head())

# Estadísticas descriptivas
print("\n" + "="*80)
print("ESTADÍSTICAS DESCRIPTIVAS")
print("="*80)
print(df.describe())

# Verificar valores nulos
print("\n" + "="*80)
print("VALORES NULOS")
print("="*80)
print(df.isnull().sum())

# Distribución de Deserción (Attrition)
print("\n" + "="*80)
print("DISTRIBUCIÓN DE DESERCIÓN")
print("="*80)
attrition_counts = df['Deserción'].value_counts()
attrition_pct = df['Deserción'].value_counts(normalize=True) * 100
print(attrition_counts)
print(f"\nPorcentaje:")
print(f"  No: {attrition_pct['No']:.2f}%")
print(f"  Yes: {attrition_pct['Yes']:.2f}%")

# =============================================================================
# PARTE 2: ANÁLISIS POR VARIABLES CLAVE
# =============================================================================

print("\n[2/6] Analizando variables clave...")

# Tasa de Deserción por Departamento
print("\n" + "="*80)
print("DESERCIÓN POR DEPARTAMENTO")
print("="*80)
dept_attrition = pd.crosstab(df['Departamento'], df['Deserción'], normalize='index') * 100
print(dept_attrition)

# Deserción por Rol de Trabajo
print("\n" + "="*80)
print("DESERCIÓN POR ROL DE TRABAJO")
print("="*80)
role_attrition = pd.crosstab(df['Rol del puesto'], df['Deserción'], normalize='index') * 100
print(role_attrition.sort_values('Yes', ascending=False))

# Deserción por Género
print("\n" + "="*80)
print("DESERCIÓN POR GÉNERO")
print("="*80)
gender_attrition = pd.crosstab(df['Género'], df['Deserción'], normalize='index') * 100
print(gender_attrition)

# Estadísticas de edad por Deserción
print("\n" + "="*80)
print("EDAD PROMEDIO POR DESERCIÓN")
print("="*80)
print(df.groupby('Deserción')['Edad'].describe())

# Salario mensual por Deserción
print("\n" + "="*80)
print("SALARIO MENSUAL PROMEDIO POR DESERCIÓN")
print("="*80)
print(df.groupby('Deserción')['Ingresos mensuales'].describe())

# Distancia desde casa por Deserción
print("\n" + "="*80)
print("DISTANCIA DESDE CASA POR DESERCIÓN")
print("="*80)
print(df.groupby('Deserción')['Distancia desde casa'].describe())

# Work-Life Balance por Deserción
print("\n" + "="*80)
print("BALANCE VIDA-TRABAJO POR DESERCIÓN")
print("="*80)
wlb_attrition = pd.crosstab(df['Balance de vida laboral'], df['Deserción'], normalize='index') * 100
print(wlb_attrition)

print("\n Análisis exploratorio completado")