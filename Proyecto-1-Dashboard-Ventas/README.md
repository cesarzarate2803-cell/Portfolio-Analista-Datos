# Proyecto 1:
# Dashboard de Ventas - Análisis Retail Superstore
## Objetivo del Proyecto
Analizar el desempeño comercial de una cadena de tiendas retail para identificar oportunidades de mejora en rentabilidad, optimizar el portafolio de productos y detectar regiones con bajo margen de ganancia.

## Preview del Dashboard

![Dashboard](Dashboard-Ventas-Superstore.pdf)

## Herramientas Utilizadas
- **Microsoft Excel**: Limpieza de datos, análisis exploratorio y tablas dinámicas
- **Power BI Desktop**: Visualización interactiva de datos y creación de dashboard
- **DAX**: Creación de medidas calculadas y KPIs

## Dataset
- Fuente: Kaggle - Superstore Sales Dataset
- Registros: 51,284 transacciones
- Período: 2011 - 2014
- Alcance: Ventas globales en múltiples regiones y categorías de productos

## Insights Clave

### Hallazgos Críticos:
- Furniture requiere revisión urgente: bajo margen (6.98%) sugiere reestructuración de precios o costos
- Southeast Asia opera con margen crítico del 2%, necesita análisis de viabilidad operativa
- Productos tecnológicos (impresoras 3D, laptops) generan pérdidas significativas, posible exceso de descuentos

### Oportunidades:
- Canada muestra el mejor margen (26.62%) - modelo replicable
- Technology combina alto volumen con buen margen - invertir en marketing
- Estacionalidad clara - optimizar inventario y promociones para Q4

## Métricas Principales (KPIs)
----------------------------------
|     Métrica      |    Valor    |
|------------------|-------------|
| Ventas Totales   | $12,640,977 |
| Ganancia Total   | $1,468,626  |
| Margen Promedio  | 11.62%      |
| Total Órdenes    | 51,284      |
| Ticket Promedio  | $246.49     |
----------------------------------

## Visualizaciones del Dashboard

1. **KPIs principales**: Ventas totales, ganancia total y margen de ganancia
2. **Ventas por Categoría**: Gráfico de barras comparativo
3. **Mapa de Ventas por Región**: Distribución geográfica con burbujas proporcionales
4. **Tendencia Temporal**: Evolución mensual de ventas y ganancias (2011-2014)
5. **Productos con Pérdidas**: Top 10 productos no rentables con formato condicional
6. **Filtros Interactivos**: Segmentación por año, mes y categoría

## Habilidades Demostradas

- Limpieza y preparación de datos (Data Cleaning)
- Análisis exploratorio de datos (EDA)
- Creación de tablas dinámicas en Excel
- Modelado de datos en Power BI
- Desarrollo de medidas DAX
- Diseño de dashboards interactivos
- Storytelling con datos
- Identificación de insights de negocio

## Preguntas de Negocio Respondidas

1. ¿Qué categoría de productos genera más ventas y cuál tiene mejor margen?
   - Technology lidera en ventas ($4.7M) con 13.99% de margen
   - Furniture tiene el margen más bajo (6.98%) a pesar de generar $4.1M en ventas

2. ¿Qué región vende más pero genera menos ganancia?
   - Southeast Asia presenta ventas de $884K pero solo 2.02% de margen
   - Indica problemas de costos operativos o descuentos excesivos

3. ¿Qué productos deberíamos dejar de vender?
   - Identificados 10+ productos con pérdidas consistentes
   - Top pérdida: Cubify CubeX 3D Printer (-$8,879.97)
   - Categoría Furniture domina la lista de productos no rentables

4. ¿Cuál es la tendencia de ventas y hay estacionalidad?
   - Crecimiento sostenido: de $2.3M (2011) a $4.3M (2014)
   - Picos estacionales en Q4 (Noviembre-Diciembre) y Septiembre
