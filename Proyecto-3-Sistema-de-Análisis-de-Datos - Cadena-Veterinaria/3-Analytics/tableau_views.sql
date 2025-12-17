-- ============================================
-- VISTAS OPTIMIZADAS PARA TABLEAU
-- Sistema Veterinaria - Queries pre-procesadas
-- ============================================

-- Estas vistas simplifican la conexión de Tableau y mejoran el rendimiento
-- Úsalas como fuentes de datos principales en Tableau

-- ============================================
-- VISTA 1: VENTAS CONSOLIDADAS (Uso principal)
-- ============================================
CREATE OR REPLACE VIEW dw.v_tableau_ventas AS
SELECT 
    -- IDs para relaciones
    fv.sk_venta,
    fv.id_venta,
    fv.sk_tiempo,
    fv.sk_cliente,
    fv.sk_sede,
    fv.sk_producto,
    fv.sk_servicio,
    
    -- Dimensión Tiempo
    t.fecha,
    t.anio AS año,
    t.mes,
    t.mes_nombre,
    t.mes_anio,
    t.trimestre,
    t.trimestre_anio,
    t.dia_semana,
    t.dia_nombre,
    t.es_fin_semana,
    
    -- Dimensión Cliente
    c.nombre_completo AS cliente,
    c.segmento_cliente,
    c.ciudad AS ciudad_cliente,
    c.antiguedad_anios AS antiguedad_cliente_años,
    
    -- Dimensión Sede
    s.nombre AS sede,
    s.ciudad AS ciudad_sede,
    s.region,
    s.zona,
    s.tipo_sede,
    
    -- Dimensión Producto (si aplica)
    CASE WHEN fv.tipo_venta = 'Producto' THEN p.nombre ELSE NULL END AS producto,
    CASE WHEN fv.tipo_venta = 'Producto' THEN p.categoria ELSE NULL END AS categoria_producto,
    
    -- Dimensión Servicio (si aplica)
    CASE WHEN fv.tipo_venta = 'Servicio' THEN srv.nombre ELSE NULL END AS servicio,
    CASE WHEN fv.tipo_venta = 'Servicio' THEN srv.categoria ELSE NULL END AS categoria_servicio,
    
    -- Atributos transaccionales
    fv.tipo_venta,
    fv.tipo_pago,
    fv.estado,
    
    -- MÉTRICAS (listas para agregaciones)
    fv.cantidad,
    fv.precio_unitario,
    fv.costo_unitario,
    fv.subtotal,
    fv.descuento,
    fv.total,
    fv.margen_unitario,
    fv.margen_total,
    
    -- Métricas calculadas adicionales
    ROUND((fv.margen_total / NULLIF(fv.total, 0)) * 100, 2) AS margen_porcentaje,
    
    -- Flags para filtros rápidos
    CASE WHEN fv.tipo_venta = 'Producto' THEN 1 ELSE 0 END AS es_producto,
    CASE WHEN fv.tipo_venta = 'Servicio' THEN 1 ELSE 0 END AS es_servicio,
    CASE WHEN t.anio = EXTRACT(YEAR FROM CURRENT_DATE) THEN 1 ELSE 0 END AS es_año_actual,
    CASE WHEN t.mes = EXTRACT(MONTH FROM CURRENT_DATE) THEN 1 ELSE 0 END AS es_mes_actual
    
FROM dw.fact_ventas fv
INNER JOIN dw.dim_tiempo t ON fv.sk_tiempo = t.sk_tiempo
LEFT JOIN dw.dim_cliente c ON fv.sk_cliente = c.sk_cliente AND c.es_actual = TRUE
LEFT JOIN dw.dim_sede s ON fv.sk_sede = s.sk_sede AND s.es_actual = TRUE
LEFT JOIN dw.dim_producto p ON fv.sk_producto = p.sk_producto AND p.es_actual = TRUE
LEFT JOIN dw.dim_servicio srv ON fv.sk_servicio = srv.sk_servicio AND srv.es_actual = TRUE;

-- Comentario para Tableau
COMMENT ON VIEW dw.v_tableau_ventas IS 'Vista consolidada de ventas para Tableau - Incluye todas las dimensiones relacionadas';

-- ============================================
-- VISTA 2: CITAS CONSOLIDADAS
-- ============================================
CREATE OR REPLACE VIEW dw.v_tableau_citas AS
SELECT 
    -- IDs
    fc.sk_cita,
    fc.id_cita,
    fc.sk_tiempo,
    fc.sk_cliente,
    fc.sk_mascota,
    fc.sk_veterinario,
    fc.sk_sede,
    
    -- Dimensión Tiempo
    t.fecha,
    t.anio AS año,
    t.mes,
    t.mes_nombre,
    t.mes_anio,
    t.trimestre,
    t.dia_semana,
    t.dia_nombre,
    t.es_fin_semana,
    fc.hora_cita,
    EXTRACT(HOUR FROM fc.hora_cita) AS hora_del_dia,
    
    -- Dimensión Cliente
    c.nombre_completo AS cliente,
    c.segmento_cliente,
    c.ciudad AS ciudad_cliente,
    
    -- Dimensión Mascota
    m.nombre AS mascota,
    m.especie,
    m.raza,
    m.grupo_edad AS grupo_edad_mascota,
    m.edad_anios AS edad_mascota,
    m.tamano,
    
    -- Dimensión Veterinario
    v.nombre_completo AS veterinario,
    v.especialidad,
    v.categoria_especialidad,
    
    -- Dimensión Sede
    s.nombre AS sede,
    s.ciudad AS ciudad_sede,
    s.region,
    s.zona,
    
    -- Atributos
    fc.motivo,
    fc.estado,
    
    -- MÉTRICAS
    fc.duracion_minutos,
    fc.costo_cita,
    
    -- Flags analíticos
    fc.es_primera_cita,
    fc.es_emergencia,
    fc.es_control,
    fc.asistio,
    
    -- Flags para filtros
    CASE WHEN fc.asistio THEN 1 ELSE 0 END AS cita_completada,
    CASE WHEN NOT fc.asistio THEN 1 ELSE 0 END AS cita_no_asistio,
    CASE WHEN t.anio = EXTRACT(YEAR FROM CURRENT_DATE) THEN 1 ELSE 0 END AS es_año_actual,
    
    -- Categorización de horarios
    CASE 
        WHEN EXTRACT(HOUR FROM fc.hora_cita) BETWEEN 8 AND 11 THEN 'Mañana'
        WHEN EXTRACT(HOUR FROM fc.hora_cita) BETWEEN 12 AND 14 THEN 'Mediodía'
        WHEN EXTRACT(HOUR FROM fc.hora_cita) BETWEEN 15 AND 18 THEN 'Tarde'
        ELSE 'Noche'
    END AS turno
    
FROM dw.fact_citas fc
INNER JOIN dw.dim_tiempo t ON fc.sk_tiempo = t.sk_tiempo
LEFT JOIN dw.dim_cliente c ON fc.sk_cliente = c.sk_cliente AND c.es_actual = TRUE
LEFT JOIN dw.dim_mascota m ON fc.sk_mascota = m.sk_mascota AND m.es_actual = TRUE
LEFT JOIN dw.dim_veterinario v ON fc.sk_veterinario = v.sk_veterinario AND v.es_actual = TRUE
LEFT JOIN dw.dim_sede s ON fc.sk_sede = s.sk_sede AND s.es_actual = TRUE;

COMMENT ON VIEW dw.v_tableau_citas IS 'Vista consolidada de citas para Tableau - Incluye análisis de asistencia y productividad';

-- ============================================
-- VISTA 3: RESUMEN MENSUAL DE INGRESOS
-- ============================================
CREATE OR REPLACE VIEW dw.v_tableau_ingresos_mensuales AS
WITH ventas_mes AS (
    SELECT 
        t.anio,
        t.mes,
        t.mes_nombre,
        t.mes_anio,
        s.nombre AS sede,
        s.ciudad,
        
        -- Métricas de ventas
        COUNT(DISTINCT fv.id_venta) AS num_ventas,
        SUM(fv.cantidad) AS unidades_vendidas,
        SUM(fv.total) AS ingresos_ventas,
        SUM(fv.margen_total) AS margen_ventas,
        
        -- Clientes
        COUNT(DISTINCT fv.sk_cliente) AS clientes_unicos
    FROM dw.fact_ventas fv
    INNER JOIN dw.dim_tiempo t ON fv.sk_tiempo = t.sk_tiempo
    INNER JOIN dw.dim_sede s ON fv.sk_sede = s.sk_sede AND s.es_actual = TRUE
    GROUP BY t.anio, t.mes, t.mes_nombre, t.mes_anio, s.nombre, s.ciudad
),
citas_mes AS (
    SELECT 
        t.anio,
        t.mes,
        s.nombre AS sede,
        
        -- Métricas de citas
        COUNT(*) AS num_citas,
        SUM(CASE WHEN fc.asistio THEN 1 ELSE 0 END) AS citas_completadas,
        SUM(fc.costo_cita) AS ingresos_citas
    FROM dw.fact_citas fc
    INNER JOIN dw.dim_tiempo t ON fc.sk_tiempo = t.sk_tiempo
    INNER JOIN dw.dim_sede s ON fc.sk_sede = s.sk_sede AND s.es_actual = TRUE
    GROUP BY t.anio, t.mes, s.nombre
)
SELECT 
    vm.anio AS año,
    vm.mes,
    vm.mes_nombre,
    vm.mes_anio,
    vm.sede,
    vm.ciudad,
    
    -- Ventas
    vm.num_ventas AS total_ventas,
    vm.unidades_vendidas,
    vm.ingresos_ventas,
    vm.margen_ventas,
    ROUND(vm.margen_ventas / NULLIF(vm.ingresos_ventas, 0) * 100, 2) AS margen_pct,
    ROUND(vm.ingresos_ventas / NULLIF(vm.num_ventas, 0), 2) AS ticket_promedio,
    
    -- Citas
    COALESCE(cm.num_citas, 0) AS total_citas,
    COALESCE(cm.citas_completadas, 0) AS citas_completadas,
    COALESCE(cm.ingresos_citas, 0) AS ingresos_citas,
    ROUND(COALESCE(cm.citas_completadas, 0)::NUMERIC / NULLIF(cm.num_citas, 0) * 100, 2) AS tasa_asistencia_pct,
    
    -- Totales
    vm.ingresos_ventas + COALESCE(cm.ingresos_citas, 0) AS ingresos_totales,
    
    -- Clientes
    vm.clientes_unicos,
    
    -- Crecimiento YoY
    LAG(vm.ingresos_ventas) OVER (
        PARTITION BY vm.mes, vm.sede 
        ORDER BY vm.anio
    ) AS ingresos_año_anterior,
    
    ROUND(
        ((vm.ingresos_ventas - LAG(vm.ingresos_ventas) OVER (
            PARTITION BY vm.mes, vm.sede 
            ORDER BY vm.anio
        )) / NULLIF(LAG(vm.ingresos_ventas) OVER (
            PARTITION BY vm.mes, vm.sede 
            ORDER BY vm.anio
        ), 0)) * 100, 2
    ) AS crecimiento_yoy_pct
    
FROM ventas_mes vm
LEFT JOIN citas_mes cm 
    ON vm.anio = cm.anio 
    AND vm.mes = cm.mes 
    AND vm.sede = cm.sede
ORDER BY vm.anio DESC, vm.mes DESC, vm.sede;

COMMENT ON VIEW dw.v_tableau_ingresos_mensuales IS 'Resumen mensual de ingresos con crecimiento YoY - Ideal para dashboards ejecutivos';

-- ============================================
-- VISTA 4: TOP PRODUCTOS
-- ============================================
CREATE OR REPLACE VIEW dw.v_tableau_top_productos AS
SELECT 
    p.nombre AS producto,
    p.categoria,
    p.tipo,
    
    -- Métricas agregadas
    COUNT(*) AS veces_vendido,
    SUM(fv.cantidad) AS unidades_totales,
    SUM(fv.total) AS ingresos_totales,
    SUM(fv.margen_total) AS margen_total,
    
    -- Promedios
    ROUND(AVG(fv.precio_unitario), 2) AS precio_promedio,
    ROUND(AVG(fv.margen_unitario), 2) AS margen_promedio,
    
    -- Porcentajes
    ROUND(SUM(fv.margen_total) / NULLIF(SUM(fv.total), 0) * 100, 2) AS margen_porcentaje,
    
    -- Ranking
    RANK() OVER (ORDER BY SUM(fv.total) DESC) AS ranking_por_ingresos,
    RANK() OVER (ORDER BY SUM(fv.margen_total) DESC) AS ranking_por_margen,
    
    -- Última venta
    MAX(t.fecha) AS ultima_venta,
    CURRENT_DATE - MAX(t.fecha) AS dias_sin_vender,
    
    -- Clasificación ABC
    CASE 
        WHEN PERCENT_RANK() OVER (ORDER BY SUM(fv.total) DESC) <= 0.20 THEN 'A - Alto Valor'
        WHEN PERCENT_RANK() OVER (ORDER BY SUM(fv.total) DESC) <= 0.50 THEN 'B - Valor Medio'
        ELSE 'C - Bajo Valor'
    END AS clasificacion_abc
    
FROM dw.fact_ventas fv
INNER JOIN dw.dim_producto p ON fv.sk_producto = p.sk_producto AND p.es_actual = TRUE
INNER JOIN dw.dim_tiempo t ON fv.sk_tiempo = t.sk_tiempo
WHERE fv.tipo_venta = 'Producto'
GROUP BY p.sk_producto, p.nombre, p.categoria, p.tipo
ORDER BY ingresos_totales DESC;

COMMENT ON VIEW dw.v_tableau_top_productos IS 'Análisis completo de productos con rankings y clasificación ABC';

-- ============================================
-- VISTA 5: ANÁLISIS RFM DE CLIENTES
-- ============================================
CREATE OR REPLACE VIEW dw.v_tableau_rfm_clientes AS
WITH rfm_base AS (
    SELECT 
        c.sk_cliente,
        c.nombre_completo AS cliente,
        c.ciudad,
        c.segmento_cliente,
        
        -- Recency: días desde última compra
        CURRENT_DATE - MAX(t.fecha) AS recency,
        
        -- Frequency: número de compras
        COUNT(DISTINCT fv.id_venta) AS frequency,
        
        -- Monetary: total gastado
        SUM(fv.total) AS monetary
        
    FROM dw.dim_cliente c
    INNER JOIN dw.fact_ventas fv ON c.sk_cliente = fv.sk_cliente
    INNER JOIN dw.dim_tiempo t ON fv.sk_tiempo = t.sk_tiempo
    WHERE c.es_actual = TRUE
    GROUP BY c.sk_cliente, c.nombre_completo, c.ciudad, c.segmento_cliente
),
rfm_scores AS (
    SELECT 
        *,
        -- Scores de 1-5 (5 es mejor)
        NTILE(5) OVER (ORDER BY recency) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_base
)
SELECT 
    sk_cliente,
    cliente,
    ciudad,
    segmento_cliente,
    
    -- Métricas RFM
    recency AS dias_desde_ultima_compra,
    frequency AS numero_compras,
    ROUND(monetary, 2) AS gasto_total,
    ROUND(monetary / frequency, 2) AS ticket_promedio,
    
    -- Scores
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    
    -- Segmentación RFM
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Campeones'
        WHEN r_score >= 4 AND f_score >= 3 THEN 'Clientes Leales'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Clientes Nuevos'
        WHEN r_score >= 3 AND m_score >= 4 THEN 'Clientes Prometedores'
        WHEN r_score <= 2 AND f_score >= 4 THEN 'En Riesgo de Pérdida'
        WHEN r_score <= 2 AND m_score >= 4 THEN 'No Podemos Perderlos'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Perdidos'
        ELSE 'Requiere Atención'
    END AS segmento_rfm,
    
    -- Flags
    CASE WHEN r_score >= 4 THEN 1 ELSE 0 END AS es_cliente_reciente,
    CASE WHEN f_score >= 4 THEN 1 ELSE 0 END AS es_cliente_frecuente,
    CASE WHEN m_score >= 4 THEN 1 ELSE 0 END AS es_alto_valor
    
FROM rfm_scores
ORDER BY monetary DESC;

COMMENT ON VIEW dw.v_tableau_rfm_clientes IS 'Segmentación RFM completa de clientes - Listo para análisis de retención';

-- ============================================
-- VISTA 6: PRODUCTIVIDAD DE VETERINARIOS
-- ============================================
CREATE OR REPLACE VIEW dw.v_tableau_productividad_veterinarios AS
SELECT 
    v.nombre_completo AS veterinario,
    v.especialidad,
    v.categoria_especialidad,
    s.nombre AS sede,
    s.ciudad,
    
    -- Métricas de citas
    COUNT(*) AS total_citas,
    SUM(CASE WHEN fc.asistio THEN 1 ELSE 0 END) AS citas_completadas,
    SUM(CASE WHEN NOT fc.asistio THEN 1 ELSE 0 END) AS citas_no_asistidas,
    
    -- Tasas
    ROUND(SUM(CASE WHEN fc.asistio THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS tasa_asistencia_pct,
    
    -- Tiempos
    ROUND(AVG(fc.duracion_minutos), 2) AS duracion_promedio_min,
    SUM(fc.duracion_minutos) AS minutos_totales,
    ROUND(SUM(fc.duracion_minutos) / 60.0, 2) AS horas_totales,
    
    -- Ingresos
    SUM(fc.costo_cita) AS ingresos_citas,
    ROUND(AVG(fc.costo_cita), 2) AS costo_promedio_cita,
    
    -- Productividad
    ROUND(SUM(fc.costo_cita) / NULLIF(SUM(fc.duracion_minutos) / 60.0, 0), 2) AS ingreso_por_hora,
    
    -- Tipos de consulta
    SUM(CASE WHEN fc.es_emergencia THEN 1 ELSE 0 END) AS consultas_emergencia,
    SUM(CASE WHEN fc.es_control THEN 1 ELSE 0 END) AS consultas_control,
    SUM(CASE WHEN fc.es_primera_cita THEN 1 ELSE 0 END) AS primeras_consultas,
    
    -- Mascotas únicas atendidas
    COUNT(DISTINCT fc.sk_mascota) AS mascotas_unicas,
    
    -- Fechas
    MIN(t.fecha) AS primera_cita,
    MAX(t.fecha) AS ultima_cita
    
FROM dw.fact_citas fc
INNER JOIN dw.dim_veterinario v ON fc.sk_veterinario = v.sk_veterinario AND v.es_actual = TRUE
INNER JOIN dw.dim_sede s ON fc.sk_sede = s.sk_sede AND s.es_actual = TRUE
INNER JOIN dw.dim_tiempo t ON fc.sk_tiempo = t.sk_tiempo
GROUP BY v.sk_veterinario, v.nombre_completo, v.especialidad, v.categoria_especialidad, s.nombre, s.ciudad
ORDER BY ingresos_citas DESC;

COMMENT ON VIEW dw.v_tableau_productividad_veterinarios IS 'Análisis de productividad y desempeño de veterinarios';

-- ============================================
-- VISTA 7: ANÁLISIS DE MASCOTAS
-- ============================================
CREATE OR REPLACE VIEW dw.v_tableau_mascotas_activas AS
SELECT 
    m.sk_mascota,
    m.nombre AS mascota,
    m.especie,
    m.raza,
    m.sexo,
    m.edad_anios AS edad,
    m.grupo_edad,
    m.tamano,
    m.peso_kg,
    
    -- Cliente dueño
    m.id_cliente,
    c.nombre_completo AS dueno,
    c.ciudad AS ciudad_dueno,
    
    -- Estadísticas de citas
    COUNT(fc.id_cita) AS total_citas,
    MAX(t.fecha) AS ultima_visita,
    MIN(t.fecha) AS primera_visita,
    CURRENT_DATE - MAX(t.fecha) AS dias_sin_visita,
    
    -- Ingresos generados
    SUM(fc.costo_cita) AS gasto_total_citas,
    ROUND(AVG(fc.costo_cita), 2) AS gasto_promedio_cita,
    
    -- Clasificación de cliente
    CASE 
        WHEN COUNT(fc.id_cita) >= 10 THEN 'VIP'
        WHEN COUNT(fc.id_cita) >= 5 THEN 'Regular'
        WHEN COUNT(fc.id_cita) >= 2 THEN 'Ocasional'
        ELSE 'Nuevo'
    END AS frecuencia_visitas,
    
    -- Alerta de seguimiento
    CASE 
        WHEN CURRENT_DATE - MAX(t.fecha) > 365 THEN 'Inactivo +1 año'
        WHEN CURRENT_DATE - MAX(t.fecha) > 180 THEN 'Necesita seguimiento'
        WHEN CURRENT_DATE - MAX(t.fecha) > 90 THEN 'Revisión recomendada'
        ELSE 'Activo'
    END AS estado_seguimiento
    
FROM dw.dim_mascota m
INNER JOIN dw.dim_cliente c ON m.id_cliente = c.id_cliente AND c.es_actual = TRUE
LEFT JOIN dw.fact_citas fc ON m.sk_mascota = fc.sk_mascota
LEFT JOIN dw.dim_tiempo t ON fc.sk_tiempo = t.sk_tiempo
WHERE m.es_actual = TRUE AND m.estado = 'Activo'
GROUP BY m.sk_mascota, m.nombre, m.especie, m.raza, m.sexo, m.edad_anios, 
         m.grupo_edad, m.tamano, m.peso_kg, m.id_cliente, c.nombre_completo, c.ciudad
ORDER BY total_citas DESC;

COMMENT ON VIEW dw.v_tableau_mascotas_activas IS 'Vista consolidada de mascotas activas con análisis de frecuencia';

-- ============================================
-- ÍNDICES ADICIONALES PARA PERFORMANCE
-- ============================================

-- Estos índices mejorarán el rendimiento en Tableau
CREATE INDEX IF NOT EXISTS idx_fact_ventas_fecha ON dw.fact_ventas(sk_tiempo);
CREATE INDEX IF NOT EXISTS idx_fact_citas_fecha ON dw.fact_citas(sk_tiempo);
CREATE INDEX IF NOT EXISTS idx_dim_tiempo_fecha ON dw.dim_tiempo(fecha);
CREATE INDEX IF NOT EXISTS idx_dim_tiempo_año_mes ON dw.dim_tiempo(anio, mes);

-- ============================================
-- VERIFICACIÓN DE VISTAS
-- ============================================

-- Para verificar que todas las vistas se crearon correctamente:
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views
WHERE schemaname = 'dw'
  AND viewname LIKE 'v_tableau%'
ORDER BY viewname;


-- ============================================