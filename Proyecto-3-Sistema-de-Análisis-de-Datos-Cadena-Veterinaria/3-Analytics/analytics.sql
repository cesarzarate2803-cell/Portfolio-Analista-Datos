-- ============================================
-- QUERIES ANALÍTICAS AVANZADAS
-- Sistema Veterinaria - Data Warehouse
-- ============================================

-- ============================================
-- 1. ANÁLISIS DE INGRESOS
-- ============================================

-- Ingresos mensuales con crecimiento YoY
WITH ingresos_mensuales AS (
    SELECT 
        t.anio,
        t.mes,
        t.mes_nombre,
        SUM(v.total) AS ingresos_mes,
        COUNT(DISTINCT v.id_venta) AS num_ventas
    FROM dw.fact_ventas v
    INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
    GROUP BY t.anio, t.mes, t.mes_nombre
)
SELECT 
    im.anio,
    im.mes,
    im.mes_nombre,
    im.ingresos_mes,
    im.num_ventas,
    LAG(im.ingresos_mes) OVER (PARTITION BY im.mes ORDER BY im.anio) AS ingresos_anio_anterior,
    ROUND(
        ((im.ingresos_mes - LAG(im.ingresos_mes) OVER (PARTITION BY im.mes ORDER BY im.anio)) 
        / NULLIF(LAG(im.ingresos_mes) OVER (PARTITION BY im.mes ORDER BY im.anio), 0) * 100), 2
    ) AS crecimiento_yoy_pct
FROM ingresos_mensuales im
ORDER BY im.anio, im.mes;

-- Ingresos por sede con ranking
SELECT 
    s.nombre AS sede,
    s.ciudad,
    COUNT(DISTINCT v.id_venta) AS total_ventas,
    SUM(v.total) AS ingresos_totales,
    ROUND(AVG(v.total), 2) AS ticket_promedio,
    RANK() OVER (ORDER BY SUM(v.total) DESC) AS ranking_ingresos
FROM dw.fact_ventas v
INNER JOIN dw.dim_sede s ON v.sk_sede = s.sk_sede
WHERE s.es_actual = TRUE
GROUP BY s.sk_sede, s.nombre, s.ciudad
ORDER BY ingresos_totales DESC;

-- ============================================
-- 2. ANÁLISIS DE PRODUCTOS
-- ============================================

-- Top 20 productos por margen de contribución
SELECT 
    p.nombre AS producto,
    p.categoria,
    COUNT(*) AS veces_vendido,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.total) AS ingresos_totales,
    SUM(v.margen_total) AS margen_total,
    ROUND(SUM(v.margen_total) / NULLIF(SUM(v.total), 0) * 100, 2) AS margen_porcentaje
FROM dw.fact_ventas v
INNER JOIN dw.dim_producto p ON v.sk_producto = p.sk_producto
WHERE v.tipo_venta = 'Producto'
  AND p.es_actual = TRUE
GROUP BY p.sk_producto, p.nombre, p.categoria
ORDER BY margen_total DESC
LIMIT 20;

-- Análisis ABC de productos (Pareto)
WITH productos_ingresos AS (
    SELECT 
        p.sk_producto,
        p.nombre,
        p.categoria,
        SUM(v.total) AS ingresos_producto,
        SUM(SUM(v.total)) OVER () AS ingresos_totales
    FROM dw.fact_ventas v
    INNER JOIN dw.dim_producto p ON v.sk_producto = p.sk_producto
    WHERE v.tipo_venta = 'Producto' AND p.es_actual = TRUE
    GROUP BY p.sk_producto, p.nombre, p.categoria
),
productos_acumulado AS (
    SELECT 
        *,
        SUM(ingresos_producto) OVER (ORDER BY ingresos_producto DESC) AS ingresos_acumulados,
        ROUND(SUM(ingresos_producto) OVER (ORDER BY ingresos_producto DESC) / ingresos_totales * 100, 2) AS pct_acumulado
    FROM productos_ingresos
)
SELECT 
    nombre,
    categoria,
    ingresos_producto,
    pct_acumulado,
    CASE 
        WHEN pct_acumulado <= 80 THEN 'A - Alto Valor'
        WHEN pct_acumulado <= 95 THEN 'B - Valor Medio'
        ELSE 'C - Bajo Valor'
    END AS clasificacion_abc
FROM productos_acumulado
ORDER BY ingresos_producto DESC;

-- Productos con menor rotación (últimos 90 días)
WITH ventas_recientes AS (
    SELECT 
        p.sk_producto,
        p.nombre,
        p.categoria,
        COUNT(*) AS veces_vendido,
        MAX(t.fecha) AS ultima_venta,
        CURRENT_DATE - MAX(t.fecha) AS dias_sin_vender
    FROM dw.fact_ventas v
    INNER JOIN dw.dim_producto p ON v.sk_producto = p.sk_producto
    INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
    WHERE v.tipo_venta = 'Producto'
      AND p.es_actual = TRUE
      AND t.fecha >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY p.sk_producto, p.nombre, p.categoria
)
SELECT 
    nombre,
    categoria,
    veces_vendido,
    ultima_venta,
    dias_sin_vender,
    CASE 
        WHEN dias_sin_vender > 60 THEN 'Crítico'
        WHEN dias_sin_vender > 30 THEN 'Atención'
        ELSE 'Normal'
    END AS alerta_rotacion
FROM ventas_recientes
WHERE dias_sin_vender > 30
ORDER BY dias_sin_vender DESC;

-- ============================================
-- 3. ANÁLISIS DE CLIENTES
-- ============================================

-- Segmentación RFM de Clientes
WITH rfm_base AS (
    SELECT 
        c.sk_cliente,
        c.nombre_completo,
        c.segmento_cliente,
        MAX(t.fecha) AS ultima_compra,
        CURRENT_DATE - MAX(t.fecha) AS recency,
        COUNT(DISTINCT v.id_venta) AS frequency,
        SUM(v.total) AS monetary
    FROM dw.fact_ventas v
    INNER JOIN dw.dim_cliente c ON v.sk_cliente = c.sk_cliente
    INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
    WHERE c.es_actual = TRUE
    GROUP BY c.sk_cliente, c.nombre_completo, c.segmento_cliente
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_base
)
SELECT 
    nombre_completo,
    segmento_cliente,
    recency AS dias_desde_ultima_compra,
    frequency AS num_compras,
    ROUND(monetary, 2) AS gasto_total,
    r_score,
    f_score,
    m_score,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Campeones'
        WHEN r_score >= 4 AND f_score >= 3 THEN 'Clientes Leales'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Clientes Nuevos'
        WHEN r_score <= 2 AND f_score >= 4 THEN 'En Riesgo'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Perdidos'
        ELSE 'Clientes Ocasionales'
    END AS segmento_rfm
FROM rfm_scores
ORDER BY monetary DESC;

-- Top 20 clientes por gasto total
SELECT 
    c.nombre_completo,
    c.ciudad,
    c.segmento_cliente,
    COUNT(DISTINCT v.id_venta) AS total_compras,
    SUM(v.cantidad) AS total_productos,
    SUM(v.total) AS gasto_total,
    ROUND(AVG(v.total), 2) AS ticket_promedio,
    MAX(t.fecha) AS ultima_compra
FROM dw.fact_ventas v
INNER JOIN dw.dim_cliente c ON v.sk_cliente = c.sk_cliente
INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
WHERE c.es_actual = TRUE
GROUP BY c.sk_cliente, c.nombre_completo, c.ciudad, c.segmento_cliente
ORDER BY gasto_total DESC
LIMIT 20;

-- Tasa de retención mensual
WITH clientes_por_mes AS (
    SELECT 
        t.anio,
        t.mes,
        t.mes_anio,
        COUNT(DISTINCT v.sk_cliente) AS clientes_activos
    FROM dw.fact_ventas v
    INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
    GROUP BY t.anio, t.mes, t.mes_anio
),
clientes_retenidos AS (
    SELECT 
        t.anio,
        t.mes,
        COUNT(DISTINCT v.sk_cliente) AS clientes_retenidos
    FROM dw.fact_ventas v
    INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
    WHERE EXISTS (
        SELECT 1 
        FROM dw.fact_ventas v2
        INNER JOIN dw.dim_tiempo t2 ON v2.sk_tiempo = t2.sk_tiempo
        WHERE v2.sk_cliente = v.sk_cliente
        AND t2.anio = t.anio
        AND t2.mes = t.mes - 1
    )
    GROUP BY t.anio, t.mes
)
SELECT 
    cp.anio,
    cp.mes,
    cp.mes_anio,
    cp.clientes_activos,
    COALESCE(cr.clientes_retenidos, 0) AS clientes_retenidos,
    ROUND(COALESCE(cr.clientes_retenidos, 0)::NUMERIC / NULLIF(cp.clientes_activos, 0) * 100, 2) AS tasa_retencion_pct
FROM clientes_por_mes cp
LEFT JOIN clientes_retenidos cr ON cp.anio = cr.anio AND cp.mes = cr.mes
ORDER BY cp.anio, cp.mes;

-- ============================================
-- 4. ANÁLISIS DE CITAS
-- ============================================

-- Productividad por veterinario
SELECT 
    v.nombre_completo,
    v.especialidad,
    s.nombre AS sede,
    COUNT(*) AS total_citas,
    SUM(CASE WHEN c.asistio THEN 1 ELSE 0 END) AS citas_completadas,
    SUM(CASE WHEN NOT c.asistio THEN 1 ELSE 0 END) AS citas_no_asistidas,
    ROUND(SUM(CASE WHEN c.asistio THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS tasa_asistencia_pct,
    ROUND(AVG(c.duracion_minutos), 2) AS duracion_promedio_min,
    SUM(c.costo_cita) AS ingresos_citas
FROM dw.fact_citas c
INNER JOIN dw.dim_veterinario v ON c.sk_veterinario = v.sk_veterinario
INNER JOIN dw.dim_sede s ON c.sk_sede = s.sk_sede
WHERE v.es_actual = TRUE AND s.es_actual = TRUE
GROUP BY v.sk_veterinario, v.nombre_completo, v.especialidad, s.nombre
ORDER BY total_citas DESC;

-- Análisis de motivos de consulta
SELECT 
    c.motivo,
    COUNT(*) AS total_citas,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2) AS porcentaje,
    SUM(CASE WHEN c.asistio THEN 1 ELSE 0 END) AS citas_asistidas,
    ROUND(AVG(c.costo_cita), 2) AS costo_promedio
FROM dw.fact_citas c
WHERE c.motivo IS NOT NULL
GROUP BY c.motivo
ORDER BY total_citas DESC
LIMIT 15;

-- Distribución de citas por hora del día
SELECT 
    EXTRACT(HOUR FROM c.hora_cita) AS hora,
    COUNT(*) AS total_citas,
    ROUND(AVG(c.duracion_minutos), 2) AS duracion_promedio
FROM dw.fact_citas c
GROUP BY EXTRACT(HOUR FROM c.hora_cita)
ORDER BY hora;

-- Días de la semana con mayor demanda
SELECT 
    t.dia_nombre,
    t.dia_semana,
    COUNT(*) AS total_citas,
    ROUND(AVG(c.costo_cita), 2) AS costo_promedio,
    SUM(CASE WHEN c.asistio THEN 1 ELSE 0 END) AS citas_asistidas
FROM dw.fact_citas c
INNER JOIN dw.dim_tiempo t ON c.sk_tiempo = t.sk_tiempo
GROUP BY t.dia_nombre, t.dia_semana
ORDER BY t.dia_semana;

-- ============================================
-- 5. ANÁLISIS DE MASCOTAS
-- ============================================

-- Distribución de mascotas por especie y edad
SELECT 
    m.especie,
    m.grupo_edad,
    COUNT(*) AS total_mascotas,
    ROUND(AVG(m.edad_anios), 1) AS edad_promedio,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (PARTITION BY m.especie) * 100, 2) AS pct_dentro_especie
FROM dw.dim_mascota m
WHERE m.es_actual = TRUE AND m.estado = 'Activo'
GROUP BY m.especie, m.grupo_edad
ORDER BY m.especie, m.grupo_edad;

-- Razas más populares por especie
SELECT 
    m.especie,
    m.raza,
    COUNT(*) AS total_mascotas,
    ROUND(AVG(m.peso_kg), 2) AS peso_promedio_kg
FROM dw.dim_mascota m
WHERE m.es_actual = TRUE 
  AND m.estado = 'Activo'
  AND m.raza NOT LIKE '%Mestizo%'
GROUP BY m.especie, m.raza
ORDER BY m.especie, total_mascotas DESC;

-- Mascotas con más citas (clientes frecuentes)
SELECT 
    m.nombre AS mascota,
    m.especie,
    m.raza,
    c.nombre_completo AS dueno,
    COUNT(DISTINCT ci.id_cita) AS total_citas,
    MAX(t.fecha) AS ultima_visita,
    SUM(ci.costo_cita) AS gasto_total_citas
FROM dw.fact_citas ci
INNER JOIN dw.dim_mascota m ON ci.sk_mascota = m.sk_mascota
INNER JOIN dw.dim_cliente c ON ci.sk_cliente = c.sk_cliente
INNER JOIN dw.dim_tiempo t ON ci.sk_tiempo = t.sk_tiempo
WHERE m.es_actual = TRUE AND c.es_actual = TRUE
GROUP BY m.sk_mascota, m.nombre, m.especie, m.raza, c.nombre_completo
ORDER BY total_citas DESC
LIMIT 20;

-- ============================================
-- 6. ANÁLISIS DE SERVICIOS
-- ============================================

-- Servicios más solicitados con rentabilidad
SELECT 
    s.nombre AS servicio,
    s.categoria,
    COUNT(*) AS veces_solicitado,
    SUM(v.total) AS ingresos_totales,
    SUM(v.margen_total) AS margen_total,
    ROUND(AVG(v.precio_unitario), 2) AS precio_promedio,
    ROUND(AVG(s.duracion_minutos), 0) AS duracion_promedio_min
FROM dw.fact_ventas v
INNER JOIN dw.dim_servicio s ON v.sk_servicio = s.sk_servicio
WHERE v.tipo_venta = 'Servicio' AND s.es_actual = TRUE
GROUP BY s.sk_servicio, s.nombre, s.categoria
ORDER BY veces_solicitado DESC;

-- ============================================
-- 7. ANÁLISIS GEOGRÁFICO
-- ============================================

-- Rendimiento por ciudad
SELECT 
    s.ciudad,
    s.region,
    COUNT(DISTINCT s.sk_sede) AS num_sedes,
    COUNT(DISTINCT v.id_venta) AS total_ventas,
    SUM(v.total) AS ingresos_totales,
    COUNT(DISTINCT c.id_cita) AS total_citas,
    COUNT(DISTINCT v.sk_cliente) AS clientes_unicos
FROM dw.dim_sede s
LEFT JOIN dw.fact_ventas v ON s.sk_sede = v.sk_sede
LEFT JOIN dw.fact_citas c ON s.sk_sede = c.sk_sede
WHERE s.es_actual = TRUE
GROUP BY s.ciudad, s.region
ORDER BY ingresos_totales DESC;

-- ============================================
-- 8. ANÁLISIS TEMPORAL
-- ============================================

-- Tendencia de ingresos últimos 12 meses
SELECT 
    t.mes_anio,
    t.anio,
    t.mes_nombre,
    COUNT(DISTINCT v.id_venta) AS num_ventas,
    SUM(v.total) AS ingresos,
    ROUND(AVG(v.total), 2) AS ticket_promedio,
    COUNT(DISTINCT v.sk_cliente) AS clientes_unicos
FROM dw.fact_ventas v
INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
WHERE t.fecha >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY t.mes_anio, t.anio, t.mes, t.mes_nombre
ORDER BY t.anio, t.mes;

-- Comparativa de trimestres
SELECT 
    t.anio,
    t.trimestre,
    t.trimestre_anio,
    COUNT(DISTINCT v.id_venta) AS total_ventas,
    SUM(v.total) AS ingresos_trimestre,
    COUNT(DISTINCT c.id_cita) AS total_citas,
    COUNT(DISTINCT v.sk_cliente) AS clientes_unicos
FROM dw.dim_tiempo t
LEFT JOIN dw.fact_ventas v ON t.sk_tiempo = v.sk_tiempo
LEFT JOIN dw.fact_citas c ON t.sk_tiempo = c.sk_tiempo
GROUP BY t.anio, t.trimestre, t.trimestre_anio
ORDER BY t.anio, t.trimestre;

-- ============================================
-- 9. CROSS-SELLING Y MARKET BASKET
-- ============================================

-- Productos que se compran juntos
WITH ventas_productos AS (
    SELECT 
        v.id_venta,
        p.nombre AS producto,
        p.categoria
    FROM dw.fact_ventas v
    INNER JOIN dw.dim_producto p ON v.sk_producto = p.sk_producto
    WHERE v.tipo_venta = 'Producto' AND p.es_actual = TRUE
)
SELECT 
    vp1.producto AS producto_1,
    vp2.producto AS producto_2,
    COUNT(DISTINCT vp1.id_venta) AS veces_comprados_juntos
FROM ventas_productos vp1
INNER JOIN ventas_productos vp2 
    ON vp1.id_venta = vp2.id_venta 
    AND vp1.producto < vp2.producto
GROUP BY vp1.producto, vp2.producto
HAVING COUNT(DISTINCT vp1.id_venta) >= 5
ORDER BY veces_comprados_juntos DESC
LIMIT 20;


-- ============================================