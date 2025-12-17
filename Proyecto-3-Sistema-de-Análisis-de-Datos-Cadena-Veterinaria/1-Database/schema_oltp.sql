-- ============================================
-- PROYECTO: Sistema de Gestión Veterinaria
-- Descripción: Schema OLTP (Operacional)
-- ============================================

-- Eliminar tablas si existen (en orden inverso por dependencias)
DROP TABLE IF EXISTS DetalleServicio CASCADE;
DROP TABLE IF EXISTS DetalleCompra CASCADE;
DROP TABLE IF EXISTS DetalleVenta CASCADE;
DROP TABLE IF EXISTS Stock_Producto CASCADE;
DROP TABLE IF EXISTS Historial_Medico CASCADE;
DROP TABLE IF EXISTS Examen CASCADE;
DROP TABLE IF EXISTS Vacuna CASCADE;
DROP TABLE IF EXISTS Tratamiento CASCADE;
DROP TABLE IF EXISTS Cita CASCADE;
DROP TABLE IF EXISTS Venta CASCADE;
DROP TABLE IF EXISTS Compra CASCADE;
DROP TABLE IF EXISTS Producto CASCADE;
DROP TABLE IF EXISTS Servicio_Adicional CASCADE;
DROP TABLE IF EXISTS Mascota CASCADE;
DROP TABLE IF EXISTS Veterinario CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;
DROP TABLE IF EXISTS Proveedor CASCADE;
DROP TABLE IF EXISTS Sede CASCADE;

-- ============================================
-- TABLA: Sede
-- ============================================
CREATE TABLE Sede (
    ID_Sede SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(150),
    Telefono VARCHAR(15),
    Ciudad VARCHAR(50),
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Estado VARCHAR(20) DEFAULT 'Activo'
);

-- ============================================
-- TABLA: Proveedor
-- ============================================
CREATE TABLE Proveedor (
    ID_Proveedor SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    Correo_Electronico VARCHAR(100) UNIQUE,
    Direccion VARCHAR(100),
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Estado VARCHAR(20) DEFAULT 'Activo'
);

-- ============================================
-- TABLA: Cliente
-- ============================================
CREATE TABLE Cliente (
    ID_Cliente SERIAL PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Telefono VARCHAR(15),
    Direccion VARCHAR(100),
    Correo_Electronico VARCHAR(100) UNIQUE,
    Dni VARCHAR(20) UNIQUE,
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Estado VARCHAR(20) DEFAULT 'Activo',
    Fecha_Ultima_Visita TIMESTAMP
);

-- ============================================
-- TABLA: Mascota
-- ============================================
CREATE TABLE Mascota (
    ID_Mascota SERIAL PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Especie VARCHAR(30) NOT NULL,
    Raza VARCHAR(50),
    Sexo CHAR(1) CHECK (Sexo IN ('M', 'H')),
    Fecha_Nacimiento DATE,
    Color VARCHAR(30),
    Peso_Kg DECIMAL(5,2),
    Estado VARCHAR(20) DEFAULT 'Activo',
    Observacion TEXT,
    ID_Cliente INTEGER NOT NULL,
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_mascota_cliente 
        FOREIGN KEY (ID_Cliente) 
        REFERENCES Cliente(ID_Cliente) 
        ON DELETE RESTRICT
);

-- ============================================
-- TABLA: Veterinario
-- ============================================
CREATE TABLE Veterinario (
    ID_Veterinario SERIAL PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Especialidad VARCHAR(100),
    Telefono VARCHAR(15),
    Correo_Electronico VARCHAR(100) UNIQUE,
    Dni VARCHAR(20) UNIQUE,
    Colegiatura VARCHAR(20) UNIQUE,
    ID_Sede INTEGER NOT NULL,
    Fecha_Contratacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Estado VARCHAR(20) DEFAULT 'Activo',
    
    CONSTRAINT fk_veterinario_sede 
        FOREIGN KEY (ID_Sede) 
        REFERENCES Sede(ID_Sede) 
        ON DELETE RESTRICT
);

-- ============================================
-- TABLA: Cita
-- ============================================
CREATE TABLE Cita (
    ID_Cita SERIAL PRIMARY KEY,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Motivo TEXT,
    Estado VARCHAR(20) DEFAULT 'Programada',
    Observacion TEXT,
    Costo DECIMAL(10,2),
    Duracion_Minutos INTEGER DEFAULT 30,
    ID_Mascota INTEGER NOT NULL,
    ID_Veterinario INTEGER NOT NULL,
    ID_Sede INTEGER NOT NULL,
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_cita_mascota 
        FOREIGN KEY (ID_Mascota) 
        REFERENCES Mascota(ID_Mascota) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_cita_veterinario 
        FOREIGN KEY (ID_Veterinario) 
        REFERENCES Veterinario(ID_Veterinario) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_cita_sede 
        FOREIGN KEY (ID_Sede) 
        REFERENCES Sede(ID_Sede) 
        ON DELETE RESTRICT,
    
    CONSTRAINT chk_cita_estado 
        CHECK (Estado IN ('Programada', 'Completada', 'Cancelada', 'En Proceso', 'No Asistió'))
);

-- ============================================
-- TABLA: Tratamiento
-- ============================================
CREATE TABLE Tratamiento (
    ID_Tratamiento SERIAL PRIMARY KEY,
    Descripcion TEXT NOT NULL,
    Medicamento VARCHAR(200),
    Dosis VARCHAR(100),
    Frecuencia VARCHAR(100),
    Duracion VARCHAR(50),
    Fecha_Inicio TIMESTAMP NOT NULL,
    Fecha_Fin TIMESTAMP,
    Estado VARCHAR(20) DEFAULT 'En Progreso',
    Costo DECIMAL(10,2),
    ID_Cita INTEGER NOT NULL,
    
    CONSTRAINT fk_tratamiento_cita 
        FOREIGN KEY (ID_Cita) 
        REFERENCES Cita(ID_Cita) 
        ON DELETE RESTRICT,
    
    CONSTRAINT chk_tratamiento_estado 
        CHECK (Estado IN ('En Progreso', 'Completado', 'Suspendido'))
);

-- ============================================
-- TABLA: Producto
-- ============================================
CREATE TABLE Producto (
    ID_Producto SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Tipo VARCHAR(50),
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio >= 0),
    Costo DECIMAL(10,2),
    Descripcion TEXT,
    Unidad_Medida VARCHAR(20),
    Categoria VARCHAR(50),
    ID_Proveedor INTEGER,
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Estado VARCHAR(20) DEFAULT 'Activo',
    
    CONSTRAINT fk_producto_proveedor 
        FOREIGN KEY (ID_Proveedor) 
        REFERENCES Proveedor(ID_Proveedor) 
        ON DELETE SET NULL
);

-- ============================================
-- TABLA: Servicio_Adicional
-- ============================================
CREATE TABLE Servicio_Adicional (
    ID_Servicio_Adicional SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio >= 0),
    Costo DECIMAL(10,2),
    Descripcion TEXT,
    Duracion_Minutos INTEGER,
    Categoria VARCHAR(50),
    Estado VARCHAR(20) DEFAULT 'Activo'
);

-- ============================================
-- TABLA: Venta
-- ============================================
CREATE TABLE Venta (
    ID_Venta SERIAL PRIMARY KEY,
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Total DECIMAL(10,2) NOT NULL CHECK (Total >= 0),
    Tipo_Pago VARCHAR(20) NOT NULL,
    Estado VARCHAR(20) DEFAULT 'Completada',
    ID_Cliente INTEGER NOT NULL,
    ID_Sede INTEGER NOT NULL,
    Descuento DECIMAL(10,2) DEFAULT 0,
    Observacion TEXT,
    
    CONSTRAINT fk_venta_cliente 
        FOREIGN KEY (ID_Cliente) 
        REFERENCES Cliente(ID_Cliente) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_venta_sede 
        FOREIGN KEY (ID_Sede) 
        REFERENCES Sede(ID_Sede) 
        ON DELETE RESTRICT,
    
    CONSTRAINT chk_venta_tipo_pago 
        CHECK (Tipo_Pago IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Yape', 'Plin'))
);

-- ============================================
-- TABLA: DetalleVenta
-- ============================================
CREATE TABLE DetalleVenta (
    ID_Detalle SERIAL PRIMARY KEY,
    ID_Venta INTEGER NOT NULL,
    ID_Producto INTEGER NOT NULL,
    Cantidad INTEGER NOT NULL CHECK (Cantidad > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    Descuento DECIMAL(10,2) DEFAULT 0,
    
    CONSTRAINT fk_detalleventa_venta 
        FOREIGN KEY (ID_Venta) 
        REFERENCES Venta(ID_Venta) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_detalleventa_producto 
        FOREIGN KEY (ID_Producto) 
        REFERENCES Producto(ID_Producto) 
        ON DELETE RESTRICT
);

-- ============================================
-- TABLA: DetalleServicio
-- ============================================
CREATE TABLE DetalleServicio (
    ID_Detalle_Servicio SERIAL PRIMARY KEY,
    ID_Venta INTEGER NOT NULL,
    ID_Servicio_Adicional INTEGER NOT NULL,
    Cantidad INTEGER NOT NULL CHECK (Cantidad > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT fk_detalleservicio_venta 
        FOREIGN KEY (ID_Venta) 
        REFERENCES Venta(ID_Venta) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_detalleservicio_servicio 
        FOREIGN KEY (ID_Servicio_Adicional) 
        REFERENCES Servicio_Adicional(ID_Servicio_Adicional) 
        ON DELETE RESTRICT
);

-- ============================================
-- TABLA: Stock_Producto
-- ============================================
CREATE TABLE Stock_Producto (
    ID_Stock SERIAL PRIMARY KEY,
    ID_Sede INTEGER NOT NULL,
    ID_Producto INTEGER NOT NULL,
    Cantidad_Disponible INTEGER NOT NULL DEFAULT 0,
    Stock_Minimo INTEGER DEFAULT 5,
    Stock_Maximo INTEGER DEFAULT 100,
    Fecha_Actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_stockproducto_sede 
        FOREIGN KEY (ID_Sede) 
        REFERENCES Sede(ID_Sede) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_stockproducto_producto 
        FOREIGN KEY (ID_Producto) 
        REFERENCES Producto(ID_Producto) 
        ON DELETE CASCADE,
    
    CONSTRAINT uk_stock_sede_producto 
        UNIQUE (ID_Sede, ID_Producto)
);

-- ============================================
-- TABLA: Compra
-- ============================================
CREATE TABLE Compra (
    ID_Compra SERIAL PRIMARY KEY,
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Total DECIMAL(10,2) NOT NULL,
    Estado VARCHAR(20) DEFAULT 'Completada',
    ID_Sede INTEGER NOT NULL,
    Observacion TEXT,
    
    CONSTRAINT fk_compra_sede 
        FOREIGN KEY (ID_Sede) 
        REFERENCES Sede(ID_Sede) 
        ON DELETE RESTRICT
);

-- ============================================
-- TABLA: DetalleCompra
-- ============================================
CREATE TABLE DetalleCompra (
    ID_Detalle_Compra SERIAL PRIMARY KEY,
    ID_Compra INTEGER NOT NULL,
    ID_Producto INTEGER NOT NULL,
    ID_Proveedor INTEGER NOT NULL,
    Cantidad INTEGER NOT NULL CHECK (Cantidad > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT fk_detallecompra_compra 
        FOREIGN KEY (ID_Compra) 
        REFERENCES Compra(ID_Compra) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_detallecompra_producto 
        FOREIGN KEY (ID_Producto) 
        REFERENCES Producto(ID_Producto) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_detallecompra_proveedor 
        FOREIGN KEY (ID_Proveedor) 
        REFERENCES Proveedor(ID_Proveedor) 
        ON DELETE RESTRICT
);

-- ============================================
-- TABLA: Vacuna
-- ============================================
CREATE TABLE Vacuna (
    ID_Vacuna SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Dosis VARCHAR(50),
    Lote VARCHAR(50),
    Fecha_Aplicacion TIMESTAMP NOT NULL,
    Fecha_Proxima TIMESTAMP,
    Costo DECIMAL(10,2),
    ID_Mascota INTEGER NOT NULL,
    ID_Veterinario INTEGER,
    Observacion TEXT,
    
    CONSTRAINT fk_vacuna_mascota 
        FOREIGN KEY (ID_Mascota) 
        REFERENCES Mascota(ID_Mascota) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_vacuna_veterinario 
        FOREIGN KEY (ID_Veterinario) 
        REFERENCES Veterinario(ID_Veterinario) 
        ON DELETE SET NULL
);

-- ============================================
-- TABLA: Examen
-- ============================================
CREATE TABLE Examen (
    ID_Examen SERIAL PRIMARY KEY,
    Tipo VARCHAR(100) NOT NULL,
    Resultado TEXT,
    Fecha TIMESTAMP NOT NULL,
    Costo DECIMAL(10,2),
    ID_Veterinario INTEGER NOT NULL,
    ID_Mascota INTEGER NOT NULL,
    Observacion TEXT,
    
    CONSTRAINT fk_examen_veterinario 
        FOREIGN KEY (ID_Veterinario) 
        REFERENCES Veterinario(ID_Veterinario) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_examen_mascota 
        FOREIGN KEY (ID_Mascota) 
        REFERENCES Mascota(ID_Mascota) 
        ON DELETE RESTRICT
);

-- ============================================
-- TABLA: Historial_Medico
-- ============================================
CREATE TABLE Historial_Medico (
    ID_Historial SERIAL PRIMARY KEY,
    Fecha TIMESTAMP NOT NULL,
    Sintomas TEXT,
    Diagnostico TEXT,
    Recomendacion TEXT,
    Observacion TEXT,
    Peso_Kg DECIMAL(5,2),
    Temperatura DECIMAL(4,2),
    ID_Veterinario INTEGER NOT NULL,
    ID_Mascota INTEGER NOT NULL,
    ID_Cita INTEGER,
    
    CONSTRAINT fk_historialmedico_veterinario 
        FOREIGN KEY (ID_Veterinario) 
        REFERENCES Veterinario(ID_Veterinario) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_historialmedico_mascota 
        FOREIGN KEY (ID_Mascota) 
        REFERENCES Mascota(ID_Mascota) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_historialmedico_cita 
        FOREIGN KEY (ID_Cita) 
        REFERENCES Cita(ID_Cita) 
        ON DELETE SET NULL
);

-- ============================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

-- Índices para búsquedas frecuentes
CREATE INDEX idx_mascota_cliente ON Mascota(ID_Cliente);
CREATE INDEX idx_mascota_especie ON Mascota(Especie);
CREATE INDEX idx_mascota_estado ON Mascota(Estado);

CREATE INDEX idx_cita_fecha ON Cita(Fecha);
CREATE INDEX idx_cita_estado ON Cita(Estado);
CREATE INDEX idx_cita_mascota ON Cita(ID_Mascota);
CREATE INDEX idx_cita_veterinario ON Cita(ID_Veterinario);
CREATE INDEX idx_cita_sede ON Cita(ID_Sede);

CREATE INDEX idx_venta_fecha ON Venta(Fecha);
CREATE INDEX idx_venta_cliente ON Venta(ID_Cliente);
CREATE INDEX idx_venta_sede ON Venta(ID_Sede);

CREATE INDEX idx_cliente_dni ON Cliente(Dni);
CREATE INDEX idx_cliente_estado ON Cliente(Estado);

CREATE INDEX idx_producto_categoria ON Producto(Categoria);
CREATE INDEX idx_producto_estado ON Producto(Estado);

CREATE INDEX idx_stock_sede ON Stock_Producto(ID_Sede);
CREATE INDEX idx_stock_producto ON Stock_Producto(ID_Producto);

CREATE INDEX idx_historial_mascota ON Historial_Medico(ID_Mascota);
CREATE INDEX idx_historial_fecha ON Historial_Medico(Fecha);

-- ============================================
-- VISTAS ÚTILES
-- ============================================

-- Vista: Mascotas con información de dueños
CREATE OR REPLACE VIEW v_mascotas_completo AS
SELECT 
    m.ID_Mascota,
    m.Nombre AS Nombre_Mascota,
    m.Especie,
    m.Raza,
    m.Sexo,
    m.Fecha_Nacimiento,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, m.Fecha_Nacimiento)) AS Edad_Anios,
    m.Color,
    m.Peso_Kg,
    m.Estado AS Estado_Mascota,
    c.ID_Cliente,
    c.Nombre || ' ' || c.Apellido AS Nombre_Dueno,
    c.Telefono AS Telefono_Dueno,
    c.Correo_Electronico AS Email_Dueno,
    c.Estado AS Estado_Cliente
FROM Mascota m
INNER JOIN Cliente c ON m.ID_Cliente = c.ID_Cliente;

-- Vista: Citas con toda la información
CREATE OR REPLACE VIEW v_citas_completo AS
SELECT 
    ci.ID_Cita,
    ci.Fecha,
    ci.Hora,
    ci.Estado AS Estado_Cita,
    ci.Motivo,
    ci.Costo,
    m.Nombre AS Nombre_Mascota,
    m.Especie,
    cl.Nombre || ' ' || cl.Apellido AS Nombre_Cliente,
    cl.Telefono AS Telefono_Cliente,
    v.Nombre || ' ' || v.Apellido AS Nombre_Veterinario,
    v.Especialidad,
    s.Nombre AS Nombre_Sede,
    s.Ciudad
FROM Cita ci
INNER JOIN Mascota m ON ci.ID_Mascota = m.ID_Mascota
INNER JOIN Cliente cl ON m.ID_Cliente = cl.ID_Cliente
INNER JOIN Veterinario v ON ci.ID_Veterinario = v.ID_Veterinario
INNER JOIN Sede s ON ci.ID_Sede = s.ID_Sede;

-- Vista: Productos con stock por sede
CREATE OR REPLACE VIEW v_inventario_completo AS
SELECT 
    p.ID_Producto,
    p.Nombre AS Nombre_Producto,
    p.Categoria,
    p.Precio,
    s.ID_Sede,
    s.Nombre AS Nombre_Sede,
    s.Ciudad,
    COALESCE(sp.Cantidad_Disponible, 0) AS Stock_Actual,
    COALESCE(sp.Stock_Minimo, 0) AS Stock_Minimo,
    CASE 
        WHEN COALESCE(sp.Cantidad_Disponible, 0) <= COALESCE(sp.Stock_Minimo, 0) 
        THEN 'Crítico'
        WHEN COALESCE(sp.Cantidad_Disponible, 0) <= COALESCE(sp.Stock_Minimo, 0) * 2 
        THEN 'Bajo'
        ELSE 'Normal'
    END AS Estado_Stock
FROM Producto p
CROSS JOIN Sede s
LEFT JOIN Stock_Producto sp ON p.ID_Producto = sp.ID_Producto AND s.ID_Sede = sp.ID_Sede
WHERE p.Estado = 'Activo';

-- ============================================
-- COMENTARIOS EN TABLAS
-- ============================================

COMMENT ON TABLE Sede IS 'Locales o sucursales de la veterinaria';
COMMENT ON TABLE Cliente IS 'Dueños de las mascotas';
COMMENT ON TABLE Mascota IS 'Mascotas registradas en el sistema';
COMMENT ON TABLE Veterinario IS 'Profesionales veterinarios';
COMMENT ON TABLE Cita IS 'Citas o consultas programadas';
COMMENT ON TABLE Producto IS 'Catálogo de productos en venta';
COMMENT ON TABLE Venta IS 'Transacciones de venta realizadas';
COMMENT ON TABLE Stock_Producto IS 'Inventario de productos por sede';


-- ============================================
