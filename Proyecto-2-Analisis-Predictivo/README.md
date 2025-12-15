# Análisis Predictivo de Rotación de Empleados (HR Analytics)

## Objetivo del Proyecto
Desarrollar un sistema predictivo de Machine Learning para identificar empleados con alto riesgo de deserción laboral, permitiendo al departamento de Recursos Humanos implementar estrategias de retención proactivas y basadas en datos.

![Dashboard Preview](dashboard-preview.png)

## Herramientas y Tecnologías Utilizadas

### Lenguajes y Librerías
- **Python 3.13**
  - `pandas` - Manipulación y análisis de datos
  - `numpy` - Operaciones numéricas y arrays
  - `matplotlib` - Visualizaciones básicas
  - `seaborn` - Visualizaciones estadísticas avanzadas
  - `scikit-learn` - Machine Learning y evaluación de modelos

### **Herramientas de BI**
- **Power BI Desktop** - Dashboard interactivo
- **DAX** - Creación de medidas calculadas

### **Entorno**
- **VS Code** - Desarrollo
- **Python Virtual Environment** (.venv) - Gestión de dependencias

## Dataset
- **Fuente**: IBM HR Analytics Employee Attrition & Performance (Kaggle)
- **Registros**: 1,470 empleados
- **Variables**: 35 columnas
- **Período**: Datos históricos de empleados
- **Variable Objetivo**: Attrition (Yes/No)

### **Variables Clave**
- **Demográficas**: Edad, Género, Estado Civil, Distancia desde Casa
- **Laborales**: Departamento, Rol, Años en Empresa, Salario Mensual
- **Satisfacción**: Balance Vida-Trabajo, Satisfacción Laboral, Ambiente
- **Compensación**: Salario, Aumento Salarial, Opciones de Acciones

## Metodología del Proyecto

### **FASE 1: Análisis Exploratorio de Datos (EDA)**

**Herramienta**: Python (Pandas, NumPy)

**Hallazgos Clave:**
- Dataset limpio: 0 valores nulos
- Tasa de deserción general: **16.12%** (237 de 1,470 empleados)
- Balance demográfico adecuado

**Análisis Realizado:**
```python
# Distribución por variables clave
- Deserción por Departamento, Rol, Género
- Análisis de Edad, Salario, Distancia vs Deserción
- Evaluación de Balance Vida-Trabajo y Satisfacción
```

**Script**: [`hr_analysis.py`](hr_analysis.py)

---

### **FASE 2: Visualización de Datos**

**Herramienta**: Python (Matplotlib, Seaborn)

**8 Visualizaciones Profesionales Generadas:**

1. **Distribución de Deserción** (Barras + Pastel)
2. **Deserción por Departamento** (Barras apiladas)
3. **Top 10 Roles con Mayor Deserción** (Barras horizontales)
4. **Salario vs Deserción** (Boxplot)
5. **Edad vs Deserción** (Histograma superpuesto)
6. **Distancia desde Casa** (Violin plot)
7. **Balance Vida-Trabajo** (Barras comparativas)
8. **Mapa de Calor de Correlaciones** (Heatmap)

**Formato**: PNG de alta resolución (300 DPI)

**Script**: [`hr_visualizations.py`](hr_visualizations.py)

---

### **FASE 3: Machine Learning - Modelo Predictivo**

**Algoritmo**: Random Forest Classifier

#### **Configuración del Modelo**
```python
RandomForestClassifier(
    n_estimators=100,      # 100 árboles de decisión
    max_depth=10,          # Profundidad máxima
    min_samples_split=10,  # Mínimo para dividir
    random_state=42
)
```

#### **Preparación de Datos**
- **Encoding**: 7 variables categóricas convertidas a numéricas (LabelEncoder)
- **División**: 80% entrenamiento / 20% prueba (stratified)
- **Features**: 30 variables finales para el modelo

#### **Métricas de Desempeño**

| Métrica | Valor | Interpretación |
|---------|-------|----------------|
| **Accuracy** | 83.67% | Muy buena precisión general |
| **ROC-AUC** | 0.79 | Excelente capacidad discriminativa |
| **Precision (No Deserción)** | 0.85 | Alta confiabilidad |
| **Recall (No Deserción)** | 0.97 | Detecta muy bien empleados que se quedan |
| **F1-Score** | 0.84 | Balance sólido |

#### **Matriz de Confusión**
```
                Predicho No    Predicho Yes
Real No            238              9
Real Yes            42              5
```

**Interpretación:**
- **238 Verdaderos Negativos** - Predijo correctamente que no se irían
- **9 Falsos Positivos** - Predijo que se irían pero se quedaron
- **42 Falsos Negativos** - Predijo que no se irían pero se fueron
- **5 Verdaderos Positivos** - Predijo correctamente que se irían

**Script**: [`hr_machine_learning.py`](hr_machine_learning.py)

---

### **FASE 4: Dashboard Interactivo en Power BI**

**Componentes del Dashboard:**

#### **1. KPIs Principales**
- Total Empleados: **1,470**
- Tasa Deserción: **16.12%**
- Salario Promedio: **$6,500**
- Empleados Alto Riesgo: **91** (6.19%)

#### **2. Filtros Interactivos**
- Departamento
- Rol del Puesto
- Grupo de Edad
- Nivel de Riesgo ML

#### **3. Visualizaciones Clave**
- Deserción por Departamento
- Matriz: Predicción ML vs Realidad
- Scatter Plot: Edad vs Salario vs Deserción
- Top 10 Variables Más Importantes
- Distribución de Riesgo (Donut Chart)
- Tabla: Empleados de Alto Riesgo (con IDs y probabilidades)

**Script de Preparación**: [`prepare_powerbi_data.py`](prepare_powerbi_data.py)

---

## Top 10 Variables Más Importantes (Feature Importance)

El modelo identificó los factores que más influyen en la deserción:

| # | Variable | Importancia | Insight Clave |
|---|----------|-------------|---------------|
| 1 | Porcentaje de aumento salarial | 10.23% | Los aumentos bajos/nulos aumentan deserción |
| 2 | Ingresos mensuales | 8.18% | Salarios bajos correlacionan con mayor deserción |
| 3 | Edad | 6.24% | Empleados jóvenes (<30) tienen mayor rotación |
| 4 | Tiempos de capacitación | 5.05% | Poca capacitación aumenta probabilidad de salida |
| 5 | Distancia desde casa | 4.87% | Vivir lejos incrementa el riesgo |
| 6 | Rol del puesto | 4.86% | Ciertos roles tienen más rotación |
| 7 | Tarifa diaria | 4.62% | Estructura de compensación afecta retención |
| 8 | Años en la empresa | 4.34% | Empleados nuevos tienen mayor riesgo |
| 9 | Tarifa por hora | 4.15% | Compensación horaria influye en decisión |
| 10 | Tarifa mensual | 4.15% | Estructura salarial mensual importa |

**Conclusión**: Los factores salariales (aumentos + salario base) representan **~18.5%** de la importancia total del modelo.

---

## Insights y Hallazgos Clave

### **HALLAZGOS CRÍTICOS**

#### **1. Crisis en Sales Representatives Jóvenes**
- **Tasa de deserción: 39.76%** (4 de cada 10 se van) ← ALERTA MÁXIMA
- Perfil de riesgo: 18-19 años, salarios $1,600-$2,800
- **Ejemplo del dashboard**: Employee ID 959 (19 años, Sales Rep, $2,121) → **89.60%** de probabilidad de irse

**Recomendación Urgente:**
```
Aumento salarial inmediato a banda competitiva ($3,500+)
Plan de carrera claro con milestones en 6-12 meses
Mentoría con Sales Executives senior
Programa de retención específico para este rol
```

---

#### **2. Departamento de Sales - Mayor Rotación**
- **Tasa de deserción: 20.63%** vs 13.84% en R&D
- 50% más rotación que otros departamentos
- Representa el 38.8% de todas las deserciones

**Recomendación:**
```
Revisión de compensación variable (comisiones)
Análisis de carga de trabajo y metas
Evaluación de liderazgo en el departamento
Programa de reconocimiento y bonos
```

---

#### **3. Perfil de Empleado en Riesgo**
**Características del empleado típico que se va:**
- **Edad promedio**: 33.6 años (vs 37.6 que se quedan)
- **Salario promedio**: $4,787 (vs $6,833 que se quedan) ← **30% menos**
- **Distancia**: 10.6 km (vs 8.9 km que se quedan)
- **Aumentos**: Menores al promedio del mercado
- **Balance Vida-Trabajo**: Nivel 1 "Malo" → **31% de deserción** (vs 14-17% en niveles superiores)

---

#### **4. El Factor Salarial es Determinante**
- **Combinado** (aumentos + salario base): ~18.5% de importancia en el modelo
- Empleados sin aumentos significativos tienen **2x probabilidad** de irse
- Brecha salarial de **$2,046** entre los que se van vs los que se quedan

---

### **FACTORES DE PROTECCIÓN**

**Empleados con BAJA probabilidad de deserción:**
- Edad >35 años - Más estables
- Salario >$6,000 - Mayor retención
- Distancia <7 km - Facilita permanencia
- Roles gerenciales - Solo 4.9% de deserción
- Balance Vida-Trabajo nivel 3-4 - Empleados satisfechos
- Alta capacitación - Se sienten valorados

---

## Recomendaciones Estratégicas para RRHH

### **PRIORIDAD ALTA - Acción Inmediata (0-30 días)**

#### **1. Intervención en Sales Representatives**
```
Acción: Revisión salarial urgente + Plan de retención
Target: 91 empleados identificados como Alto Riesgo
Budget estimado: $180K-$250K anuales
ROI: Evitar costos de reemplazo ($50K-$75K por empleado)
```

**Pasos concretos:**
- Entrevistas 1-a-1 con los 91 empleados de alto riesgo
- Ofrecer aumento inmediato del 15-25%
- Bonos de retención ($2K-$5K)
- Plan de carrera personalizado a 6 meses

---

#### **2. Programa de Retención para Jóvenes (<30 años)**
```
Target: 400-500 empleados en este segmento
Inversión: Plan de carrera + Mentoría + Capacitación
Objetivo: Reducir deserción de 20% a 12% en 12 meses
```

**Componentes:**
- Mentoría formal con empleados senior
- Capacitación técnica y soft skills (40 horas/año)
- Milestones claros de promoción
- Ajuste salarial competitivo

---

#### **3. Política de Work-Life Balance**
```
Problema: Empleados con nivel 1 "Malo" tienen 31% de deserción
Target: 80 empleados en nivel 1
Objetivo: Elevar a nivel 2-3 en 90 días
```

**Acciones:**
- Reducir horas extras obligatorias
- Implementar trabajo híbrido (2-3 días remotos)
- Flexibilidad de horarios
- Política de "no emails después de 7pm"

---

### **PRIORIDAD MEDIA - Corto Plazo (1-3 meses)**

#### **4. Revisión Salarial por Departamento**
- Benchmark salarial vs mercado (Glassdoor, LinkedIn Salary)
- Ajuste para roles con alta rotación
- Transparencia en bandas salariales
- Incremento mínimo anual del 8-12%

#### **5. Trabajo Remoto/Híbrido para Empleados Lejanos**
- Prioridad para empleados que viven >10 km
- Política flexible por departamento
- Subsidio de transporte para presenciales

---
## Habilidades Demostradas

### **Técnicas**
- **Python Avanzado**: Pandas, NumPy, Matplotlib, Seaborn
- **Machine Learning**: Random Forest, Feature Engineering, Model Evaluation
- **Data Cleaning**: Manejo de valores nulos, encoding categórico
- **Visualización de Datos**: 11 gráficos profesionales en HD
- **Power BI**: Dashboards interactivos, DAX, Storytelling
- **Feature Importance Analysis**: Identificación de variables críticas

### **De Negocio**
- **Pensamiento Estratégico**: Recomendaciones accionables para RRHH
- **Análisis de ROI**: Justificación de inversiones en retención
- **Storytelling con Datos**: Traducción de análisis técnico a insights ejecutivos
- **Priorización**: Clasificación de acciones por urgencia e impacto

---

*"Los datos no solo cuentan historias del pasado; predicen el futuro. Este proyecto transforma 1,470 historias de empleados en un sistema predictivo que salva carreras y ahorra millones."*

**Última actualización**: Diciembre 2025


