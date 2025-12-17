-- ============================================
-- DATA WAREHOUSE - VETERINARIA
-- Modelo Dimensional (Esquema Estrella)
-- ============================================

-- Crear schema separado para DW
CREATE SCHEMA IF NOT EXISTS dw;

-- ============================================
-- DIMENSIONES
-- ============================================

-- DIMENSIÓN: Tiempo (dim_tiempo)
-- Jerarquía: Año > Trimestre > Mes > Semana > Día
-- ============================================
DROP TABLE IF EXISTS dw.dim_tiempo CASCADE;

CREATE TABLE dw.dim_tiempo (
    sk_tiempo SERIAL PRIMARY KEY,
    fecha DATE UNIQUE NOT NULL,
    
    -- Día
    dia INTEGER NOT NULL,
    dia_semana INTEGER NOT NULL,  -- 1=Lunes, 7=Domingo
    dia_nombre VARCHAR(15) NOT NULL,
    dia_corto VARCHAR(3) NOT NULL,
    dia_anio INTEGER NOT NULL,
    es_fin_semana BOOLEAN NOT NULL,
    es_feriado BOOLEAN DEFAULT FALSE,
    
    -- Semana
    semana_anio INTEGER NOT NULL,
    semana_mes INTEGER NOT NULL,
    
    -- Mes
    mes INTEGER NOT NULL,
    mes_nombre VARCHAR(15) NOT NULL,
    mes_corto VARCHAR(3) NOT NULL,
    mes_anio VARCHAR(7) NOT NULL,  -- 'YYYY-MM'
    
    -- Trimestre
    trimestre INTEGER NOT NULL,
    trimestre_anio VARCHAR(7) NOT NULL,  -- 'YYYY-Q1'
    
    -- Año
    anio INTEGER NOT NULL,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Poblar dimensión tiempo (2020-2025)
INSERT INTO dw.dim_tiempo (
    fecha, dia, dia_semana, dia_nombre, dia_corto, dia_anio, es_fin_semana,
    semana_anio, semana_mes, mes, mes_nombre, mes_corto, mes_anio,
    trimestre, trimestre_anio, anio
)
SELECT 
    fecha,
    EXTRACT(DAY FROM fecha)::INTEGER,
    EXTRACT(ISODOW FROM fecha)::INTEGER,
    CASE EXTRACT(ISODOW FROM fecha)
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END,
    CASE EXTRACT(ISODOW FROM fecha)
        WHEN 1 THEN 'Lun'
        WHEN 2 THEN 'Mar'
        WHEN 3 THEN 'Mié'
        WHEN 4 THEN 'Jue'
        WHEN 5 THEN 'Vie'
        WHEN 6 THEN 'Sáb'
        WHEN 7 THEN 'Dom'
    END,
    EXTRACT(DOY FROM fecha)::INTEGER,
    EXTRACT(ISODOW FROM fecha) IN (6, 7),
    EXTRACT(WEEK FROM fecha)::INTEGER,
    CEIL(EXTRACT(DAY FROM fecha) / 7.0)::INTEGER,
    EXTRACT(MONTH FROM fecha)::INTEGER,
    CASE EXTRACT(MONTH FROM fecha)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END,
    TO_CHAR(fecha, 'Mon'),
    TO_CHAR(fecha, 'YYYY-MM'),
    EXTRACT(QUARTER FROM fecha)::INTEGER,
    EXTRACT(YEAR FROM fecha) || '-Q' || EXTRACT(QUARTER FROM fecha),
    EXTRACT(YEAR FROM fecha)::INTEGER
FROM generate_series(
    '2020-01-01'::DATE,
    '2025-12-31'::DATE,
    '1 day'::INTERVAL
) AS fecha;

-- ============================================
-- DIMENSIÓN: Cliente (dim_cliente)
-- ============================================
DROP TABLE IF EXISTS dw.dim_cliente CASCADE;

CREATE TABLE dw.dim_cliente (
    sk_cliente SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    
    -- Información personal
    nombre_completo VARCHAR(150) NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni VARCHAR(20),
    telefono VARCHAR(15),
    correo_electronico VARCHAR(100),
    
    -- Información geográfica
    direccion VARCHAR(100),
    distrito VARCHAR(50),
    ciudad VARCHAR(50),
    
    -- Segmentación
    segmento_cliente VARCHAR(30),  -- VIP, Premium, Regular, Ocasional
    antiguedad_anios INTEGER,
    
    -- Estado
    estado VARCHAR(20),
    fecha_registro DATE,
    fecha_ultima_visita DATE,
    
    -- SCD Type 2
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    version INTEGER NOT NULL,
    es_actual BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_cliente_id ON dw.dim_cliente(id_cliente);
CREATE INDEX idx_dim_cliente_actual ON dw.dim_cliente(es_actual);

-- ============================================
-- DIMENSIÓN: Mascota (dim_mascota)
-- ============================================
DROP TABLE IF EXISTS dw.dim_mascota CASCADE;

CREATE TABLE dw.dim_mascota (
    sk_mascota SERIAL PRIMARY KEY,
    id_mascota INTEGER NOT NULL,
    
    -- Información básica
    nombre VARCHAR(50) NOT NULL,
    especie VARCHAR(30) NOT NULL,
    raza VARCHAR(50),
    sexo CHAR(1),
    color VARCHAR(30),
    
    -- Información física
    peso_kg DECIMAL(5,2),
    edad_anios INTEGER,
    grupo_edad VARCHAR(20),  -- Cachorro, Adulto, Senior
    
    -- Clasificación
    tamano VARCHAR(20),  -- Pequeño, Mediano, Grande
    categoria_raza VARCHAR(30),  -- Pura Raza, Mestizo
    
    -- Estado
    estado VARCHAR(20),
    fecha_nacimiento DATE,
    fecha_registro DATE,
    
    -- Relación con cliente
    id_cliente INTEGER,
    
    -- SCD Type 2
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    version INTEGER NOT NULL,
    es_actual BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_mascota_id ON dw.dim_mascota(id_mascota);
CREATE INDEX idx_dim_mascota_especie ON dw.dim_mascota(especie);
CREATE INDEX idx_dim_mascota_actual ON dw.dim_mascota(es_actual);

-- ============================================
-- DIMENSIÓN: Veterinario (dim_veterinario)
-- ============================================
DROP TABLE IF EXISTS dw.dim_veterinario CASCADE;

CREATE TABLE dw.dim_veterinario (
    sk_veterinario SERIAL PRIMARY KEY,
    id_veterinario INTEGER NOT NULL,
    
    -- Información personal
    nombre_completo VARCHAR(150) NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni VARCHAR(20),
    colegiatura VARCHAR(20),
    
    -- Información profesional
    especialidad VARCHAR(100),
    categoria_especialidad VARCHAR(30),  -- General, Especialista
    telefono VARCHAR(15),
    correo_electronico VARCHAR(100),
    
    -- Experiencia
    fecha_contratacion DATE,
    anios_experiencia INTEGER,
    
    -- Asignación
    id_sede INTEGER,
    
    -- Estado
    estado VARCHAR(20),
    
    -- SCD Type 2
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    version INTEGER NOT NULL,
    es_actual BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_veterinario_id ON dw.dim_veterinario(id_veterinario);
CREATE INDEX idx_dim_veterinario_esp ON dw.dim_veterinario(especialidad);
CREATE INDEX idx_dim_veterinario_actual ON dw.dim_veterinario(es_actual);

-- ============================================
-- DIMENSIÓN: Sede (dim_sede)
-- ============================================
DROP TABLE IF EXISTS dw.dim_sede CASCADE;

CREATE TABLE dw.dim_sede (
    sk_sede SERIAL PRIMARY KEY,
    id_sede INTEGER NOT NULL,
    
    -- Información básica
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(20),
    
    -- Ubicación
    direccion VARCHAR(150),
    ciudad VARCHAR(50),
    region VARCHAR(50),
    zona VARCHAR(30),  -- Norte, Sur, Este, Oeste, Centro
    
    -- Clasificación
    tipo_sede VARCHAR(30),  -- Central, Sucursal
    categoria VARCHAR(20),  -- A, B, C
    
    -- Contacto
    telefono VARCHAR(15),
    
    -- Estado
    estado VARCHAR(20),
    fecha_apertura DATE,
    
    -- SCD Type 2
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    version INTEGER NOT NULL,
    es_actual BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_sede_id ON dw.dim_sede(id_sede);
CREATE INDEX idx_dim_sede_ciudad ON dw.dim_sede(ciudad);
CREATE INDEX idx_dim_sede_actual ON dw.dim_sede(es_actual);

-- ============================================
-- DIMENSIÓN: Producto (dim_producto)
-- ============================================
DROP TABLE IF EXISTS dw.dim_producto CASCADE;

CREATE TABLE dw.dim_producto (
    sk_producto SERIAL PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    
    -- Información básica
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    
    -- Clasificación
    tipo VARCHAR(50),
    categoria VARCHAR(50),
    subcategoria VARCHAR(50),
    marca VARCHAR(50),
    
    -- Medidas
    unidad_medida VARCHAR(20),
    
    -- Precios
    precio_actual DECIMAL(10,2),
    costo_actual DECIMAL(10,2),
    margen_actual DECIMAL(10,2),
    
    -- Proveedor
    id_proveedor INTEGER,
    nombre_proveedor VARCHAR(100),
    
    -- Estado
    estado VARCHAR(20),
    
    -- SCD Type 2
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    version INTEGER NOT NULL,
    es_actual BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_producto_id ON dw.dim_producto(id_producto);
CREATE INDEX idx_dim_producto_cat ON dw.dim_producto(categoria);
CREATE INDEX idx_dim_producto_actual ON dw.dim_producto(es_actual);

-- ============================================
-- DIMENSIÓN: Servicio (dim_servicio)
-- ============================================
DROP TABLE IF EXISTS dw.dim_servicio CASCADE;

CREATE TABLE dw.dim_servicio (
    sk_servicio SERIAL PRIMARY KEY,
    id_servicio INTEGER NOT NULL,
    
    -- Información básica
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    
    -- Clasificación
    categoria VARCHAR(50),
    tipo VARCHAR(50),
    
    -- Características
    duracion_minutos INTEGER,
    
    -- Precios
    precio_actual DECIMAL(10,2),
    costo_actual DECIMAL(10,2),
    margen_actual DECIMAL(10,2),
    
    -- Estado
    estado VARCHAR(20),
    
    -- SCD Type 2
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    version INTEGER NOT NULL,
    es_actual BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_servicio_id ON dw.dim_servicio(id_servicio);
CREATE INDEX idx_dim_servicio_cat ON dw.dim_servicio(categoria);
CREATE INDEX idx_dim_servicio_actual ON dw.dim_servicio(es_actual);

-- ============================================
-- TABLA DE HECHOS: Citas (fact_citas)
-- ============================================
DROP TABLE IF EXISTS dw.fact_citas CASCADE;

CREATE TABLE dw.fact_citas (
    sk_cita BIGSERIAL PRIMARY KEY,
    
    -- Claves foráneas (dimensiones)
    sk_tiempo INTEGER NOT NULL REFERENCES dw.dim_tiempo(sk_tiempo),
    sk_cliente INTEGER REFERENCES dw.dim_cliente(sk_cliente),
    sk_mascota INTEGER REFERENCES dw.dim_mascota(sk_mascota),
    sk_veterinario INTEGER REFERENCES dw.dim_veterinario(sk_veterinario),
    sk_sede INTEGER REFERENCES dw.dim_sede(sk_sede),
    
    -- Claves degeneradas
    id_cita INTEGER NOT NULL,
    hora_cita TIME,
    
    -- Atributos descriptivos
    motivo VARCHAR(500),
    estado VARCHAR(20),
    
    -- Métricas
    duracion_minutos INTEGER,
    costo_cita DECIMAL(10,2),
    
    -- Flags analíticos
    es_primera_cita BOOLEAN,
    es_emergencia BOOLEAN,
    es_control BOOLEAN,
    asistio BOOLEAN,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_citas_tiempo ON dw.fact_citas(sk_tiempo);
CREATE INDEX idx_fact_citas_mascota ON dw.fact_citas(sk_mascota);
CREATE INDEX idx_fact_citas_veterinario ON dw.fact_citas(sk_veterinario);
CREATE INDEX idx_fact_citas_sede ON dw.fact_citas(sk_sede);
CREATE INDEX idx_fact_citas_estado ON dw.fact_citas(estado);

-- ============================================
-- TABLA DE HECHOS: Ventas (fact_ventas)
-- ============================================
DROP TABLE IF EXISTS dw.fact_ventas CASCADE;

CREATE TABLE dw.fact_ventas (
    sk_venta BIGSERIAL PRIMARY KEY,
    
    -- Claves foráneas (dimensiones)
    sk_tiempo INTEGER NOT NULL REFERENCES dw.dim_tiempo(sk_tiempo),
    sk_cliente INTEGER REFERENCES dw.dim_cliente(sk_cliente),
    sk_sede INTEGER REFERENCES dw.dim_sede(sk_sede),
    sk_producto INTEGER REFERENCES dw.dim_producto(sk_producto),
    sk_servicio INTEGER REFERENCES dw.dim_servicio(sk_servicio),
    
    -- Claves degeneradas
    id_venta INTEGER NOT NULL,
    numero_linea INTEGER,
    
    -- Atributos descriptivos
    tipo_venta VARCHAR(20),  -- Producto, Servicio
    tipo_pago VARCHAR(20),
    estado VARCHAR(20),
    
    -- Métricas
    cantidad INTEGER,
    precio_unitario DECIMAL(10,2),
    costo_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    descuento DECIMAL(10,2),
    total DECIMAL(10,2),
    
    -- Métricas calculadas
    margen_unitario DECIMAL(10,2),
    margen_total DECIMAL(10,2),
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_ventas_tiempo ON dw.fact_ventas(sk_tiempo);
CREATE INDEX idx_fact_ventas_cliente ON dw.fact_ventas(sk_cliente);
CREATE INDEX idx_fact_ventas_sede ON dw.fact_ventas(sk_sede);
CREATE INDEX idx_fact_ventas_producto ON dw.fact_ventas(sk_producto);
CREATE INDEX idx_fact_ventas_tipo ON dw.fact_ventas(tipo_venta);

-- ============================================
-- TABLA DE HECHOS: Tratamientos (fact_tratamientos)
-- ============================================
DROP TABLE IF EXISTS dw.fact_tratamientos CASCADE;

CREATE TABLE dw.fact_tratamientos (
    sk_tratamiento BIGSERIAL PRIMARY KEY,
    
    -- Claves foráneas
    sk_tiempo INTEGER NOT NULL REFERENCES dw.dim_tiempo(sk_tiempo),
    sk_mascota INTEGER REFERENCES dw.dim_mascota(sk_mascota),
    sk_veterinario INTEGER REFERENCES dw.dim_veterinario(sk_veterinario),
    sk_cita BIGINT REFERENCES dw.fact_citas(sk_cita),
    
    -- Claves degeneradas
    id_tratamiento INTEGER NOT NULL,
    
    -- Atributos
    descripcion TEXT,
    medicamento VARCHAR(200),
    diagnostico VARCHAR(200),
    estado VARCHAR(20),
    
    -- Métricas
    duracion_dias INTEGER,
    costo_tratamiento DECIMAL(10,2),
    
    -- Flags
    es_cronico BOOLEAN,
    requiere_seguimiento BOOLEAN,
    
    -- Metadata
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_trat_tiempo ON dw.fact_tratamientos(sk_tiempo);
CREATE INDEX idx_fact_trat_mascota ON dw.fact_tratamientos(sk_mascota);
CREATE INDEX idx_fact_trat_vet ON dw.fact_tratamientos(sk_veterinario);

-- ============================================
-- VISTAS ANALÍTICAS
-- ============================================

-- Vista: Resumen de Ventas por Mes
CREATE OR REPLACE VIEW dw.v_ventas_mensuales AS
SELECT 
    t.anio,
    t.mes,
    t.mes_nombre,
    s.ciudad,
    COUNT(DISTINCT v.id_venta) AS total_ventas,
    SUM(v.cantidad) AS total_unidades,
    SUM(v.total) AS total_ingresos,
    SUM(v.margen_total) AS total_margen,
    ROUND(AVG(v.total), 2) AS ticket_promedio
FROM dw.fact_ventas v
INNER JOIN dw.dim_tiempo t ON v.sk_tiempo = t.sk_tiempo
INNER JOIN dw.dim_sede s ON v.sk_sede = s.sk_sede
WHERE s.es_actual = TRUE
GROUP BY t.anio, t.mes, t.mes_nombre, s.ciudad
ORDER BY t.anio, t.mes, s.ciudad;

-- Vista: Top Productos
CREATE OR REPLACE VIEW dw.v_top_productos AS
SELECT 
    p.nombre,
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.cantidad) AS total_unidades,
    SUM(v.total) AS ingresos_totales,
    ROUND(AVG(v.margen_unitario), 2) AS margen_promedio
FROM dw.fact_ventas v
INNER JOIN dw.dim_producto p ON v.sk_producto = p.sk_producto
WHERE p.es_actual = TRUE
  AND v.tipo_venta = 'Producto'
GROUP BY p.sk_producto, p.nombre, p.categoria
ORDER BY ingresos_totales DESC;

-- Vista: Análisis de Citas
CREATE OR REPLACE VIEW dw.v_analisis_citas AS
SELECT 
    t.anio,
    t.mes_nombre,
    s.nombre AS sede,
    v.especialidad,
    COUNT(*) AS total_citas,
    SUM(CASE WHEN c.asistio THEN 1 ELSE 0 END) AS citas_asistidas,
    SUM(CASE WHEN NOT c.asistio THEN 1 ELSE 0 END) AS citas_no_asistidas,
    ROUND(AVG(c.costo_cita), 2) AS costo_promedio,
    SUM(c.costo_cita) AS ingresos_totales
FROM dw.fact_citas c
INNER JOIN dw.dim_tiempo t ON c.sk_tiempo = t.sk_tiempo
INNER JOIN dw.dim_sede s ON c.sk_sede = s.sk_sede
INNER JOIN dw.dim_veterinario v ON c.sk_veterinario = v.sk_veterinario
WHERE s.es_actual = TRUE AND v.es_actual = TRUE
GROUP BY t.anio, t.mes, t.mes_nombre, s.nombre, v.especialidad
ORDER BY t.anio, t.mes, s.nombre;

-- ============================================
-- COMENTARIOS
-- ============================================

COMMENT ON SCHEMA dw IS 'Data Warehouse - Modelo Dimensional para Análisis';
COMMENT ON TABLE dw.dim_tiempo IS 'Dimensión temporal con jerarquías completas';
COMMENT ON TABLE dw.fact_citas IS 'Hechos de citas veterinarias';
COMMENT ON TABLE dw.fact_ventas IS 'Hechos de ventas (productos y servicios)';
COMMENT ON TABLE dw.fact_tratamientos IS 'Hechos de tratamientos médicos';



-- ============================================