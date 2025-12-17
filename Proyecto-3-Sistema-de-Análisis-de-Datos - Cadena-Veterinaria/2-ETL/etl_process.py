"""
============================================
ETL - VETERINARIA
Extrae datos del OLTP y carga al Data Warehouse
============================================
"""

import psycopg2
from datetime import datetime, date
import sys

# ============================================
# CONFIGURACIÓN
# ============================================
DB_CONFIG = {
    'host': 'localhost',
    'database': 'db_veterinaria',
    'user': 'postgres',
    'password': 'postadmin',
    'port': 5432
}

# ============================================
# FUNCIONES AUXILIARES
# ============================================

def conectar_db():
    """Conecta a PostgreSQL"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("Conexión exitosa a PostgreSQL")
        return conn
    except Exception as e:
        print(f" Error de conexión: {e}")
        sys.exit(1)

def log_proceso(mensaje):
    """Imprime log con timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {mensaje}")

# ============================================
# CARGA DE DIMENSIONES
# ============================================

def cargar_dim_cliente(cursor):
    """Carga dimensión Cliente (SCD Type 2)"""
    log_proceso("Cargando dim_cliente...")
    
    # Cerrar registros antiguos que ya no están en la fuente
    cursor.execute("""
        UPDATE dw.dim_cliente dc
        SET fecha_fin = CURRENT_DATE - 1, es_actual = FALSE
        WHERE dc.es_actual = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM Cliente c WHERE c.ID_Cliente = dc.id_cliente
        );
    """)
    
    # Insertar nuevos clientes o versiones actualizadas
    cursor.execute("""
        INSERT INTO dw.dim_cliente (
            id_cliente, nombre_completo, nombre, apellido, dni, telefono,
            correo_electronico, direccion, ciudad, segmento_cliente,
            antiguedad_anios, estado, fecha_registro, fecha_inicio, version, es_actual
        )
        SELECT 
            c.ID_Cliente,
            c.Nombre || ' ' || c.Apellido AS nombre_completo,
            c.Nombre,
            c.Apellido,
            c.Dni,
            c.Telefono,
            c.Correo_Electronico,
            c.Direccion,
            CASE 
                WHEN c.Direccion LIKE '%Lima%' THEN 'Lima'
                WHEN c.Direccion LIKE '%Arequipa%' THEN 'Arequipa'
                ELSE 'Otra'
            END AS ciudad,
            CASE 
                WHEN DATE_PART('year', AGE(CURRENT_DATE, c.Fecha_Registro)) >= 3 THEN 'VIP'
                WHEN DATE_PART('year', AGE(CURRENT_DATE, c.Fecha_Registro)) >= 1 THEN 'Regular'
                ELSE 'Nuevo'
            END AS segmento_cliente,
            DATE_PART('year', AGE(CURRENT_DATE, c.Fecha_Registro))::INTEGER AS antiguedad_anios,
            c.Estado,
            c.Fecha_Registro::DATE,
            CURRENT_DATE AS fecha_inicio,
            1 AS version,
            TRUE AS es_actual
        FROM Cliente c
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.dim_cliente dc 
            WHERE dc.id_cliente = c.ID_Cliente 
            AND dc.es_actual = TRUE
        );
    """)
    
    registros = cursor.rowcount
    log_proceso(f" dim_cliente: {registros} registros procesados")

def cargar_dim_mascota(cursor):
    """Carga dimensión Mascota (SCD Type 2)"""
    log_proceso("Cargando dim_mascota...")
    
    cursor.execute("""
        UPDATE dw.dim_mascota dm
        SET fecha_fin = CURRENT_DATE - 1, es_actual = FALSE
        WHERE dm.es_actual = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM Mascota m WHERE m.ID_Mascota = dm.id_mascota
        );
    """)
    
    cursor.execute("""
        INSERT INTO dw.dim_mascota (
            id_mascota, nombre, especie, raza, sexo, color, peso_kg,
            edad_anios, grupo_edad, tamano, categoria_raza, estado,
            fecha_nacimiento, id_cliente, fecha_inicio, version, es_actual
        )
        SELECT 
            m.ID_Mascota,
            m.Nombre,
            m.Especie,
            m.Raza,
            m.Sexo,
            m.Color,
            m.Peso_Kg,
            DATE_PART('year', AGE(CURRENT_DATE, m.Fecha_Nacimiento))::INTEGER AS edad_anios,
            CASE 
                WHEN DATE_PART('year', AGE(CURRENT_DATE, m.Fecha_Nacimiento)) < 1 THEN 'Cachorro'
                WHEN DATE_PART('year', AGE(CURRENT_DATE, m.Fecha_Nacimiento)) < 7 THEN 'Adulto'
                ELSE 'Senior'
            END AS grupo_edad,
            CASE 
                WHEN m.Especie = 'Perro' AND m.Peso_Kg < 10 THEN 'Pequeño'
                WHEN m.Especie = 'Perro' AND m.Peso_Kg < 25 THEN 'Mediano'
                WHEN m.Especie = 'Perro' THEN 'Grande'
                ELSE 'N/A'
            END AS tamano,
            CASE 
                WHEN m.Raza LIKE '%Mestizo%' THEN 'Mestizo'
                ELSE 'Pura Raza'
            END AS categoria_raza,
            m.Estado,
            m.Fecha_Nacimiento,
            m.ID_Cliente,
            CURRENT_DATE AS fecha_inicio,
            1 AS version,
            TRUE AS es_actual
        FROM Mascota m
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.dim_mascota dm 
            WHERE dm.id_mascota = m.ID_Mascota 
            AND dm.es_actual = TRUE
        );
    """)
    
    registros = cursor.rowcount
    log_proceso(f" dim_mascota: {registros} registros procesados")

def cargar_dim_veterinario(cursor):
    """Carga dimensión Veterinario (SCD Type 2)"""
    log_proceso("Cargando dim_veterinario...")
    
    cursor.execute("""
        UPDATE dw.dim_veterinario dv
        SET fecha_fin = CURRENT_DATE - 1, es_actual = FALSE
        WHERE dv.es_actual = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM Veterinario v WHERE v.ID_Veterinario = dv.id_veterinario
        );
    """)
    
    cursor.execute("""
        INSERT INTO dw.dim_veterinario (
            id_veterinario, nombre_completo, nombre, apellido, dni, colegiatura,
            especialidad, categoria_especialidad, telefono, correo_electronico,
            fecha_contratacion, anios_experiencia, id_sede, estado,
            fecha_inicio, version, es_actual
        )
        SELECT 
            v.ID_Veterinario,
            v.Nombre || ' ' || v.Apellido AS nombre_completo,
            v.Nombre,
            v.Apellido,
            v.Dni,
            v.Colegiatura,
            v.Especialidad,
            CASE 
                WHEN v.Especialidad = 'Medicina General' THEN 'General'
                ELSE 'Especialista'
            END AS categoria_especialidad,
            v.Telefono,
            v.Correo_Electronico,
            v.Fecha_Contratacion::DATE,
            DATE_PART('year', AGE(CURRENT_DATE, v.Fecha_Contratacion))::INTEGER AS anios_experiencia,
            v.ID_Sede,
            v.Estado,
            CURRENT_DATE AS fecha_inicio,
            1 AS version,
            TRUE AS es_actual
        FROM Veterinario v
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.dim_veterinario dv 
            WHERE dv.id_veterinario = v.ID_Veterinario 
            AND dv.es_actual = TRUE
        );
    """)
    
    registros = cursor.rowcount
    log_proceso(f" dim_veterinario: {registros} registros procesados")

def cargar_dim_sede(cursor):
    """Carga dimensión Sede (SCD Type 2)"""
    log_proceso("Cargando dim_sede...")
    
    cursor.execute("""
        UPDATE dw.dim_sede ds
        SET fecha_fin = CURRENT_DATE - 1, es_actual = FALSE
        WHERE ds.es_actual = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM Sede s WHERE s.ID_Sede = ds.id_sede
        );
    """)
    
    cursor.execute("""
        INSERT INTO dw.dim_sede (
            id_sede, nombre, direccion, ciudad, region, zona,
            tipo_sede, telefono, estado, fecha_inicio, version, es_actual
        )
        SELECT 
            s.ID_Sede,
            s.Nombre,
            s.Direccion,
            s.Ciudad,
            CASE 
                WHEN s.Ciudad IN ('Lima') THEN 'Lima Metropolitana'
                WHEN s.Ciudad IN ('Arequipa', 'Cusco') THEN 'Sur'
                WHEN s.Ciudad IN ('Trujillo', 'Chiclayo', 'Piura') THEN 'Norte'
                ELSE 'Centro'
            END AS region,
            CASE 
                WHEN s.Nombre LIKE '%Central%' THEN 'Centro'
                WHEN s.Ciudad = 'Lima' THEN 'Lima'
                ELSE 'Provincia'
            END AS zona,
            CASE 
                WHEN s.Nombre LIKE '%Central%' THEN 'Central'
                ELSE 'Sucursal'
            END AS tipo_sede,
            s.Telefono,
            s.Estado,
            CURRENT_DATE AS fecha_inicio,
            1 AS version,
            TRUE AS es_actual
        FROM Sede s
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.dim_sede ds 
            WHERE ds.id_sede = s.ID_Sede 
            AND ds.es_actual = TRUE
        );
    """)
    
    registros = cursor.rowcount
    log_proceso(f" dim_sede: {registros} registros procesados")

def cargar_dim_producto(cursor):
    """Carga dimensión Producto (SCD Type 2)"""
    log_proceso("Cargando dim_producto...")
    
    cursor.execute("""
        UPDATE dw.dim_producto dp
        SET fecha_fin = CURRENT_DATE - 1, es_actual = FALSE
        WHERE dp.es_actual = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM Producto p WHERE p.ID_Producto = dp.id_producto
        );
    """)
    
    cursor.execute("""
        INSERT INTO dw.dim_producto (
            id_producto, nombre, descripcion, tipo, categoria, unidad_medida,
            precio_actual, costo_actual, margen_actual, id_proveedor,
            nombre_proveedor, estado, fecha_inicio, version, es_actual
        )
        SELECT 
            p.ID_Producto,
            p.Nombre,
            p.Descripcion,
            p.Tipo,
            p.Categoria,
            p.Unidad_Medida,
            p.Precio,
            p.Costo,
            COALESCE(p.Precio - p.Costo, 0) AS margen_actual,
            p.ID_Proveedor,
            prov.Nombre AS nombre_proveedor,
            p.Estado,
            CURRENT_DATE AS fecha_inicio,
            1 AS version,
            TRUE AS es_actual
        FROM Producto p
        LEFT JOIN Proveedor prov ON p.ID_Proveedor = prov.ID_Proveedor
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.dim_producto dp 
            WHERE dp.id_producto = p.ID_Producto 
            AND dp.es_actual = TRUE
        );
    """)
    
    registros = cursor.rowcount
    log_proceso(f" dim_producto: {registros} registros procesados")

def cargar_dim_servicio(cursor):
    """Carga dimensión Servicio (SCD Type 2)"""
    log_proceso("Cargando dim_servicio...")
    
    cursor.execute("""
        UPDATE dw.dim_servicio ds
        SET fecha_fin = CURRENT_DATE - 1, es_actual = FALSE
        WHERE ds.es_actual = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM Servicio_Adicional s WHERE s.ID_Servicio_Adicional = ds.id_servicio
        );
    """)
    
    cursor.execute("""
        INSERT INTO dw.dim_servicio (
            id_servicio, nombre, descripcion, categoria, duracion_minutos,
            precio_actual, costo_actual, margen_actual, estado,
            fecha_inicio, version, es_actual
        )
        SELECT 
            s.ID_Servicio_Adicional,
            s.Nombre,
            s.Descripcion,
            s.Categoria,
            s.Duracion_Minutos,
            s.Precio,
            s.Costo,
            COALESCE(s.Precio - s.Costo, 0) AS margen_actual,
            s.Estado,
            CURRENT_DATE AS fecha_inicio,
            1 AS version,
            TRUE AS es_actual
        FROM Servicio_Adicional s
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.dim_servicio ds 
            WHERE ds.id_servicio = s.ID_Servicio_Adicional 
            AND ds.es_actual = TRUE
        );
    """)
    
    registros = cursor.rowcount
    log_proceso(f" dim_servicio: {registros} registros procesados")

# ============================================
# CARGA DE HECHOS
# ============================================

def cargar_fact_citas(cursor):
    """Carga tabla de hechos de Citas"""
    log_proceso("Cargando fact_citas...")
    
    cursor.execute("""
        INSERT INTO dw.fact_citas (
            sk_tiempo, sk_cliente, sk_mascota, sk_veterinario, sk_sede,
            id_cita, hora_cita, motivo, estado, duracion_minutos, costo_cita,
            es_primera_cita, es_emergencia, es_control, asistio
        )
        SELECT 
            t.sk_tiempo,
            dc.sk_cliente,
            dm.sk_mascota,
            dv.sk_veterinario,
            ds.sk_sede,
            c.ID_Cita,
            c.Hora,
            c.Motivo,
            c.Estado,
            c.Duracion_Minutos,
            c.Costo,
            -- Flags analíticos
            (SELECT COUNT(*) FROM Cita c2 
             WHERE c2.ID_Mascota = c.ID_Mascota 
             AND c2.Fecha < c.Fecha) = 0 AS es_primera_cita,
            c.Motivo LIKE '%mergencia%' AS es_emergencia,
            c.Motivo LIKE '%ontrol%' AS es_control,
            c.Estado = 'Completada' AS asistio
        FROM Cita c
        INNER JOIN dw.dim_tiempo t ON c.Fecha = t.fecha
        INNER JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
        INNER JOIN dw.dim_mascota dm ON m.ID_Mascota = dm.id_mascota AND dm.es_actual = TRUE
        INNER JOIN Cliente cl ON m.ID_Cliente = cl.ID_Cliente
        INNER JOIN dw.dim_cliente dc ON cl.ID_Cliente = dc.id_cliente AND dc.es_actual = TRUE
        INNER JOIN dw.dim_veterinario dv ON c.ID_Veterinario = dv.id_veterinario AND dv.es_actual = TRUE
        INNER JOIN dw.dim_sede ds ON c.ID_Sede = ds.id_sede AND ds.es_actual = TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.fact_citas fc WHERE fc.id_cita = c.ID_Cita
        );
    """)
    
    registros = cursor.rowcount
    log_proceso(f" fact_citas: {registros} registros procesados")

def cargar_fact_ventas(cursor):
    """Carga tabla de hechos de Ventas"""
    log_proceso("Cargando fact_ventas...")
    
    # Ventas de productos
    cursor.execute("""
        INSERT INTO dw.fact_ventas (
            sk_tiempo, sk_cliente, sk_sede, sk_producto, sk_servicio,
            id_venta, numero_linea, tipo_venta, tipo_pago, estado,
            cantidad, precio_unitario, costo_unitario, subtotal, descuento, total,
            margen_unitario, margen_total
        )
        SELECT 
            t.sk_tiempo,
            dc.sk_cliente,
            ds.sk_sede,
            dp.sk_producto,
            NULL AS sk_servicio,
            v.ID_Venta,
            dv.ID_Detalle AS numero_linea,
            'Producto' AS tipo_venta,
            v.Tipo_Pago,
            v.Estado,
            dv.Cantidad,
            dv.Precio_Unitario,
            COALESCE(p.Costo, 0) AS costo_unitario,
            dv.Subtotal,
            COALESCE(dv.Descuento, 0),
            dv.Subtotal - COALESCE(dv.Descuento, 0) AS total,
            dv.Precio_Unitario - COALESCE(p.Costo, 0) AS margen_unitario,
            (dv.Precio_Unitario - COALESCE(p.Costo, 0)) * dv.Cantidad AS margen_total
        FROM Venta v
        INNER JOIN DetalleVenta dv ON v.ID_Venta = dv.ID_Venta
        INNER JOIN Producto p ON dv.ID_Producto = p.ID_Producto
        INNER JOIN dw.dim_tiempo t ON v.Fecha::DATE = t.fecha
        INNER JOIN dw.dim_cliente dc ON v.ID_Cliente = dc.id_cliente AND dc.es_actual = TRUE
        INNER JOIN dw.dim_sede ds ON v.ID_Sede = ds.id_sede AND ds.es_actual = TRUE
        INNER JOIN dw.dim_producto dp ON p.ID_Producto = dp.id_producto AND dp.es_actual = TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.fact_ventas fv 
            WHERE fv.id_venta = v.ID_Venta 
            AND fv.numero_linea = dv.ID_Detalle
            AND fv.tipo_venta = 'Producto'
        );
    """)
    
    registros_productos = cursor.rowcount
    
    # Ventas de servicios
    cursor.execute("""
        INSERT INTO dw.fact_ventas (
            sk_tiempo, sk_cliente, sk_sede, sk_producto, sk_servicio,
            id_venta, numero_linea, tipo_venta, tipo_pago, estado,
            cantidad, precio_unitario, costo_unitario, subtotal, descuento, total,
            margen_unitario, margen_total
        )
        SELECT 
            t.sk_tiempo,
            dc.sk_cliente,
            ds.sk_sede,
            NULL AS sk_producto,
            dsv.sk_servicio,
            v.ID_Venta,
            dsrv.ID_Detalle_Servicio AS numero_linea,
            'Servicio' AS tipo_venta,
            v.Tipo_Pago,
            v.Estado,
            dsrv.Cantidad,
            dsrv.Precio_Unitario,
            COALESCE(s.Costo, 0) AS costo_unitario,
            dsrv.Subtotal,
            0 AS descuento,
            dsrv.Subtotal AS total,
            dsrv.Precio_Unitario - COALESCE(s.Costo, 0) AS margen_unitario,
            (dsrv.Precio_Unitario - COALESCE(s.Costo, 0)) * dsrv.Cantidad AS margen_total
        FROM Venta v
        INNER JOIN DetalleServicio dsrv ON v.ID_Venta = dsrv.ID_Venta
        INNER JOIN Servicio_Adicional s ON dsrv.ID_Servicio_Adicional = s.ID_Servicio_Adicional
        INNER JOIN dw.dim_tiempo t ON v.Fecha::DATE = t.fecha
        INNER JOIN dw.dim_cliente dc ON v.ID_Cliente = dc.id_cliente AND dc.es_actual = TRUE
        INNER JOIN dw.dim_sede ds ON v.ID_Sede = ds.id_sede AND ds.es_actual = TRUE
        INNER JOIN dw.dim_servicio dsv ON s.ID_Servicio_Adicional = dsv.id_servicio AND dsv.es_actual = TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM dw.fact_ventas fv 
            WHERE fv.id_venta = v.ID_Venta 
            AND fv.numero_linea = dsrv.ID_Detalle_Servicio
            AND fv.tipo_venta = 'Servicio'
        );
    """)
    
    registros_servicios = cursor.rowcount
    total_registros = registros_productos + registros_servicios
    
    log_proceso(f" fact_ventas: {total_registros} registros procesados ({registros_productos} productos, {registros_servicios} servicios)")

# ============================================
# FUNCIÓN PRINCIPAL
# ============================================

def ejecutar_etl():
    """Ejecuta el proceso ETL completo"""
    print("""
    ═══════════════════════════════════════════
    ETL - SISTEMA VETERINARIA
    OLTP → Data Warehouse
    ═══════════════════════════════════════════
    """)
    
    inicio = datetime.now()
    log_proceso("Iniciando proceso ETL...")
    
    # Conectar
    conn = conectar_db()
    cursor = conn.cursor()
    
    try:
        # FASE 1: Cargar Dimensiones
        log_proceso("\n=== FASE 1: CARGA DE DIMENSIONES ===")
        cargar_dim_cliente(cursor)
        cargar_dim_mascota(cursor)
        cargar_dim_veterinario(cursor)
        cargar_dim_sede(cursor)
        cargar_dim_producto(cursor)
        cargar_dim_servicio(cursor)
        conn.commit()
        log_proceso(" Dimensiones cargadas exitosamente")
        
        # FASE 2: Cargar Hechos
        log_proceso("\n=== FASE 2: CARGA DE HECHOS ===")
        cargar_fact_citas(cursor)
        conn.commit()
        
        cargar_fact_ventas(cursor)
        conn.commit()
        
        log_proceso(" Hechos cargados exitosamente")
        
        # Resumen final
        fin = datetime.now()
        duracion = (fin - inicio).total_seconds()
        
        print("\n" + "="*50)
        print(" ETL COMPLETADO EXITOSAMENTE ")
        print("="*50)
        log_proceso(f" Duración total: {duracion:.2f} segundos")
        
        # Estadísticas
        print("\nRESUMEN DEL DATA WAREHOUSE:")
        tablas_dw = [
            'dim_cliente', 'dim_mascota', 'dim_veterinario', 'dim_sede',
            'dim_producto', 'dim_servicio', 'fact_citas', 'fact_ventas'
        ]
        
        for tabla in tablas_dw:
            cursor.execute(f"SELECT COUNT(*) FROM dw.{tabla}")
            count = cursor.fetchone()[0]
            print(f"  dw.{tabla}: {count:,} registros")
        
    except Exception as e:
        conn.rollback()
        log_proceso(f" ERROR EN ETL: {e}")
        raise
    
    finally:
        cursor.close()
        conn.close()
        log_proceso(" Conexión cerrada")

if __name__ == "__main__":
    ejecutar_etl()