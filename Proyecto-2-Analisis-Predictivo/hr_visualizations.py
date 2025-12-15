"""
=============================================================================
PROYECTO 2 - PARTE 2: VISUALIZACIONES
Análisis Visual de Rotación de Empleados
=============================================================================
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

# Configuración de estilo
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("Set2")
plt.rcParams['figure.figsize'] = (12, 6)
plt.rcParams['font.size'] = 10

print("="*80)
print("GENERANDO VISUALIZACIONES PROFESIONALES")
print("="*80)

# Cargar datos
df = pd.read_excel('data/HR-Employee-Attrition.xlsx')
df.columns = df.columns.str.strip()  # Limpiar nombres
print(f"\n Dataset cargado: {len(df)} registros")

# Crear carpeta outputs si no existe
import os
if not os.path.exists('outputs'):
    os.makedirs('outputs')
    print(" Carpeta 'outputs' creada")

# =============================================================================
# GRAFICO 1: DISTRIBUCIÓN DE DESERCIÓN
# =============================================================================

print("\n[1/8] Creando GRAFICO de distribución de Deserción...")

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# GRAFICO de barras
attrition_counts = df['Deserción'].value_counts()
colors = ['#2ecc71', '#e74c3c']
axes[0].bar(attrition_counts.index, attrition_counts.values, color=colors, edgecolor='black')
axes[0].set_title('Distribución de Deserción', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Deserción')
axes[0].set_ylabel('Número de Empleados')
for i, v in enumerate(attrition_counts.values):
    axes[0].text(i, v + 20, str(v), ha='center', fontweight='bold')

# GRAFICO de pastel
attrition_pct = df['Deserción'].value_counts()
axes[1].pie(attrition_pct.values, labels=attrition_pct.index, autopct='%1.1f%%',
            colors=colors, startangle=90, explode=(0, 0.1), shadow=True)
axes[1].set_title('Porcentaje de Deserción', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('outputs/01_attrition_distribution.png', dpi=300, bbox_inches='tight')
print("    Guardado: 01_attrition_distribution.png")
plt.close()

# =============================================================================
# GRAFICO 2: DESERCIÓN POR DEPARTAMENTO
# =============================================================================

print("[2/8] Creando GRAFICO de Deserción por Departamento...")

dept_attrition = pd.crosstab(df['Departamento'], df['Deserción'], normalize='index') * 100

fig, ax = plt.subplots(figsize=(10, 6))
dept_attrition.plot(kind='bar', ax=ax, color=['#2ecc71', '#e74c3c'], edgecolor='black')
ax.set_title('Tasa de Deserción por Departamento', fontsize=14, fontweight='bold')
ax.set_xlabel('Departamento', fontsize=12)
ax.set_ylabel('Porcentaje (%)', fontsize=12)
ax.legend(title='Deserción', labels=['No', 'Yes'])
ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')

# Agregar valores sobre las barras
for container in ax.containers:
    ax.bar_label(container, fmt='%.1f%%', padding=3)

plt.tight_layout()
plt.savefig('outputs/02_attrition_by_department.png', dpi=300, bbox_inches='tight')
print("    Guardado: 02_attrition_by_department.png")
plt.close()

# =============================================================================
# GRAFICO 3: TOP 10 ROLES CON MAYOR DESERCIÓN
# =============================================================================

print("[3/8] Creando GRAFICO de Top 10 Roles con Mayor Deserción...")

role_attrition = pd.crosstab(df['Rol del puesto'], df['Deserción'], normalize='index') * 100
role_attrition_sorted = role_attrition.sort_values('Yes', ascending=False).head(10)

fig, ax = plt.subplots(figsize=(12, 6))
role_attrition_sorted['Yes'].plot(kind='barh', ax=ax, color='#e74c3c', edgecolor='black')
ax.set_title('Top 10 Roles con Mayor Tasa de Deserción', fontsize=14, fontweight='bold')
ax.set_xlabel('Tasa de Deserción (%)', fontsize=12)
ax.set_ylabel('Rol de Trabajo', fontsize=12)

# Agregar valores
for i, v in enumerate(role_attrition_sorted['Yes']):
    ax.text(v + 0.5, i, f'{v:.1f}%', va='center', fontweight='bold')

plt.tight_layout()
plt.savefig('outputs/03_top10_roles_attrition.png', dpi=300, bbox_inches='tight')
print("    Guardado: 03_top10_roles_attrition.png")
plt.close()

# =============================================================================
# GRAFICO 4: SALARIO MENSUAL VS DESERCIÓN (BOXPLOT)
# =============================================================================

print("[4/8] Creando GRAFICO de Salario vs Deserción...")

fig, ax = plt.subplots(figsize=(10, 6))
sns.boxplot(data=df, x='Deserción', y='Ingresos mensuales', palette=['#2ecc71', '#e74c3c'], ax=ax)
ax.set_title('Distribución de Salario Mensual por Deserción', fontsize=14, fontweight='bold')
ax.set_xlabel('Deserción', fontsize=12)
ax.set_ylabel('Salario Mensual ($)', fontsize=12)

# Agregar promedios
means = df.groupby('Deserción')['Ingresos mensuales'].mean()
positions = range(len(means))
for pos, mean in zip(positions, means):
    ax.text(pos, mean, f'μ = ${mean:.0f}', ha='center', va='bottom', 
            fontweight='bold', color='darkblue', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('outputs/04_salary_vs_attrition.png', dpi=300, bbox_inches='tight')
print("    Guardado: 04_salary_vs_attrition.png")
plt.close()

# =============================================================================
# GRAFICO 5: EDAD VS DESERCIÓN (DISTRIBUCIÓN)
# =============================================================================

print("[5/8] Creando GRAFICO de Edad vs Deserción...")

fig, ax = plt.subplots(figsize=(12, 6))
df[df['Deserción'] == 'No']['Edad'].hist(bins=20, alpha=0.7, label='No', color='#2ecc71', ax=ax, edgecolor='black')
df[df['Deserción'] == 'Yes']['Edad'].hist(bins=20, alpha=0.7, label='Yes', color='#e74c3c', ax=ax, edgecolor='black')
ax.set_title('Distribución de Edad por Deserción', fontsize=14, fontweight='bold')
ax.set_xlabel('Edad', fontsize=12)
ax.set_ylabel('Frecuencia', fontsize=12)
ax.legend(title='Deserción')

# Agregar líneas de promedio
mean_no = df[df['Deserción'] == 'No']['Edad'].mean()
mean_yes = df[df['Deserción'] == 'Yes']['Edad'].mean()
ax.axvline(mean_no, color='#2ecc71', linestyle='--', linewidth=2, label=f'Promedio No: {mean_no:.1f}')
ax.axvline(mean_yes, color='#e74c3c', linestyle='--', linewidth=2, label=f'Promedio Yes: {mean_yes:.1f}')
ax.legend()

plt.tight_layout()
plt.savefig('outputs/05_age_distribution.png', dpi=300, bbox_inches='tight')
print("    Guardado: 05_age_distribution.png")
plt.close()

# =============================================================================
# GRAFICO 6: DISTANCIA DESDE CASA VS DESERCIÓN
# =============================================================================

print("[6/8] Creando GRAFICO de Distancia desde Casa vs Deserción...")

fig, ax = plt.subplots(figsize=(10, 6))
sns.violinplot(data=df, x='Deserción', y='Distancia desde casa', palette=['#2ecc71', '#e74c3c'], ax=ax)
ax.set_title('Distancia desde Casa por Deserción', fontsize=14, fontweight='bold')
ax.set_xlabel('Deserción', fontsize=12)
ax.set_ylabel('Distancia desde Casa (km)', fontsize=12)

# Agregar promedios
means = df.groupby('Deserción')['Distancia desde casa'].mean()
positions = range(len(means))
for pos, mean in zip(positions, means):
    ax.text(pos, mean, f'μ = {mean:.1f} km', ha='center', va='bottom', 
            fontweight='bold', color='darkblue', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('outputs/06_distance_vs_attrition.png', dpi=300, bbox_inches='tight')
print("    Guardado: 06_distance_vs_attrition.png")
plt.close()

# =============================================================================
# GRAFICO 7: WORK-LIFE BALANCE VS DESERCIÓN
# =============================================================================

print("[7/8] Creando GRAFICO de Balance Vida-Trabajo vs Deserción...")

wlb_attrition = pd.crosstab(df['Balance de vida laboral'], df['Deserción'], normalize='index') * 100

fig, ax = plt.subplots(figsize=(10, 6))
wlb_attrition.plot(kind='bar', ax=ax, color=['#2ecc71', '#e74c3c'], edgecolor='black')
ax.set_title('Tasa de Deserción por Balance Vida-Trabajo', fontsize=14, fontweight='bold')
ax.set_xlabel('Balance Vida-Trabajo (1=Malo, 4=Mejor)', fontsize=12)
ax.set_ylabel('Porcentaje (%)', fontsize=12)
ax.legend(title='Deserción', labels=['No', 'Yes'])
ax.set_xticklabels(['1 (Malo)', '2 (Bueno)', '3 (Mejor)', '4 (Óptimo)'], rotation=0)

# Agregar valores
for container in ax.containers:
    ax.bar_label(container, fmt='%.1f%%', padding=3)

plt.tight_layout()
plt.savefig('outputs/07_worklifebalance_attrition.png', dpi=300, bbox_inches='tight')
print("    Guardado: 07_worklifebalance_attrition.png")
plt.close()

# =============================================================================
# GRAFICO 8: MAPA DE CALOR - CORRELACIONES
# =============================================================================

print("[8/8] Creando mapa de calor de correlaciones...")

# Seleccionar solo columnas numéricas relevantes
numeric_cols = ['Edad', 'Tarifa diaria', 'Distancia desde casa', 'Ingresos mensuales', 
                'Tarifa mensual', 'Núm. de empresas trabajadas', 
                'Total de años trabajados', 'Años en la empresa', 'Años en el puesto actual',
                'Años desde el último ascenso', 'Años con el gerente actual']

# Crear variable numérica de Deserción
df['Deserción_Numeric'] = df['Deserción'].map({'No': 0, 'Yes': 1})

# Calcular correlaciones
correlation_matrix = df[numeric_cols + ['Deserción_Numeric']].corr()

# Crear mapa de calor
fig, ax = plt.subplots(figsize=(14, 10))
sns.heatmap(correlation_matrix, annot=True, fmt='.2f', cmap='RdYlGn', center=0,
            square=True, linewidths=1, cbar_kws={"shrink": 0.8}, ax=ax)
ax.set_title('Mapa de Calor - Correlaciones con Deserción', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('outputs/08_correlation_heatmap.png', dpi=300, bbox_inches='tight')
print("    Guardado: 08_correlation_heatmap.png")
plt.close()

# =============================================================================
# RESUMEN
# =============================================================================

print("\n" + "="*80)
print(" VISUALIZACIONES COMPLETADAS")
print("="*80)
print("\nSe generaron 8 GRAFICOs profesionales en la carpeta 'outputs':")
print("  1. Distribución de Deserción")
print("  2. Deserción por Departamento")
print("  3. Top 10 Roles con Mayor Deserción")
print("  4. Salario vs Deserción")
print("  5. Edad vs Deserción")
print("  6. Distancia desde Casa vs Deserción")
print("  7. Balance Vida-Trabajo vs Deserción")
print("  8. Mapa de Calor de Correlaciones")
print("="*80)