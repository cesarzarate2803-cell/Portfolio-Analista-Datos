-- ============================================
-- DATOS INICIALES - PostgreSQL
-- ============================================

-- ============================================
-- INSERTAR SEDES
-- ============================================
INSERT INTO Sede (Nombre, Direccion, Telefono, Ciudad) VALUES 
('Sede Central Lima', 'Av. Javier Prado 1234', '01-234-5678', 'Lima'),
('Sede San Isidro', 'Av. Conquistadores 456', '01-345-6789', 'Lima'),
('Sede Miraflores', 'Av. Larco 789', '01-456-7890', 'Lima'),
('Sede Surco', 'Av. Primavera 321', '01-567-8901', 'Lima'),
('Sede Arequipa', 'Calle Mercaderes 147', '054-258-369', 'Arequipa'),
('Sede Cusco', 'Av. El Sol 258', '084-369-147', 'Cusco'),
('Sede Trujillo', 'Av. España 369', '044-147-258', 'Trujillo'),
('Sede Chiclayo', 'Av. Balta 741', '074-852-963', 'Chiclayo'),
('Sede Huancayo', 'Av. Real 456', '064-789-123', 'Huancayo'),
('Sede Piura', 'Av. Grau 321', '073-456-789', 'Piura');

-- ============================================
-- INSERTAR PROVEEDORES
-- ============================================
INSERT INTO Proveedor (Nombre, Telefono, Correo_Electronico, Direccion) VALUES 
('Pet Food Distribuidores', '987654321', 'ventas@petfood.com', 'Av. Industrial 123'),
('Medicamentos Veterinarios SAC', '912345678', 'info@medvet.com', 'Jr. Salud 456'),
('Accesorios para Mascotas', '956789123', 'contacto@accpet.com', 'Av. Comercio 789'),
('Laboratorio VetPharm', '934567890', 'lab@vetpharm.com', 'Calle Investigación 321'),
('Distribuidora Animal Care', '923456789', 'ventas@animalcare.com', 'Av. Cuidado 654'),
('Productos Caninos Premium', '945678901', 'info@caninospremium.com', 'Jr. Premium 987'),
('Veterinary Supplies Co.', '967890123', 'supplies@vetco.com', 'Av. Suministros 147'),
('Pet Nutrition International', '978901234', 'nutrition@petint.com', 'Calle Nutrición 258');

-- ============================================
-- INSERTAR CLIENTES
-- ============================================
INSERT INTO Cliente (Nombre, Apellido, Telefono, Direccion, Correo_Electronico, Dni) VALUES 
('Carlos', 'García', '987654321', 'Av. Los Pinos 123', 'carlos.garcia@email.com', '12345678'),
('María', 'López', '912345678', 'Jr. Las Flores 456', 'maria.lopez@email.com', '23456789'),
('José', 'Rodríguez', '934567890', 'Av. Central 789', 'jose.rodriguez@email.com', '34567890'),
('Ana', 'Martínez', '956789123', 'Calle Luna 321', 'ana.martinez@email.com', '45678901'),
('Luis', 'Hernández', '978901234', 'Av. Sol 654', 'luis.hernandez@email.com', '56789012'),
('Carmen', 'González', '901234567', 'Jr. Esperanza 987', 'carmen.gonzalez@email.com', '67890123'),
('Pedro', 'Sánchez', '923456789', 'Av. Libertad 147', 'pedro.sanchez@email.com', '78901234'),
('Rosa', 'Morales', '945678901', 'Calle Paz 258', 'rosa.morales@email.com', '89012345'),
('Miguel', 'Castro', '967890123', 'Av. Progreso 369', 'miguel.castro@email.com', '90123456'),
('Elena', 'Vargas', '989012345', 'Jr. Victoria 741', 'elena.vargas@email.com', '01234567');

-- ============================================
-- INSERTAR VETERINARIOS
-- ============================================
INSERT INTO Veterinario (Nombre, Apellido, Especialidad, Telefono, Correo_Electronico, Dni, Colegiatura, ID_Sede) VALUES 
('Juan', 'Pérez', 'Medicina General', '987654321', 'juan.perez@vetclinic.com', '20123456', 'VET001', 1),
('Carmen', 'Ruiz', 'Cirugía', '912345678', 'carmen.ruiz@vetclinic.com', '20234567', 'VET002', 2),
('Roberto', 'Silva', 'Dermatología', '934567890', 'roberto.silva@vetclinic.com', '20345678', 'VET003', 3),
('Ana', 'García', 'Cardiología', '956789123', 'ana.garcia@vetclinic.com', '20456789', 'VET004', 4),
('Luis', 'Mendoza', 'Oncología', '978901234', 'luis.mendoza@vetclinic.com', '20567890', 'VET005', 5),
('María', 'Torres', 'Neurología', '901234567', 'maria.torres@vetclinic.com', '20678901', 'VET006', 6),
('Carlos', 'López', 'Medicina General', '923456789', 'carlos.lopez@vetclinic.com', '20789012', 'VET007', 7),
('Patricia', 'Morales', 'Pediatría Veterinaria', '945678901', 'patricia.morales@vetclinic.com', '20890123', 'VET008', 8);

-- ============================================
-- INSERTAR MASCOTAS
-- ============================================
INSERT INTO Mascota (Nombre, Especie, Raza, Sexo, Fecha_Nacimiento, Color, Peso_Kg, Estado, Observacion, ID_Cliente) VALUES 
('Max', 'Perro', 'Golden Retriever', 'M', '2020-05-15', 'Dorado', 28.5, 'Activo', 'Muy juguetón', 1),
('Luna', 'Gato', 'Persa', 'H', '2021-03-10', 'Blanco', 4.2, 'Activo', 'Tranquila', 2),
('Rocky', 'Perro', 'Pastor Alemán', 'M', '2019-08-22', 'Negro', 35.0, 'Activo', 'Guardián', 3),
('Mia', 'Gato', 'Siamés', 'H', '2022-01-05', 'Gris', 3.8, 'Activo', 'Muy cariñosa', 4),
('Buddy', 'Perro', 'Labrador', 'M', '2020-11-18', 'Chocolate', 30.2, 'Activo', 'Nadador', 5),
('Nala', 'Gato', 'Maine Coon', 'H', '2021-06-30', 'Atigrado', 5.5, 'Activo', 'Grande y peluda', 6),
('Zeus', 'Perro', 'Rottweiler', 'M', '2019-12-12', 'Negro', 45.0, 'Activo', 'Protector', 7),
('Chloe', 'Gato', 'Bengalí', 'H', '2020-09-25', 'Manchado', 4.0, 'Activo', 'Muy activa', 8),
('Duke', 'Perro', 'Bulldog', 'M', '2021-02-14', 'Blanco', 25.0, 'Activo', 'Tranquilo', 9),
('Bella', 'Gato', 'Ragdoll', 'H', '2020-07-08', 'Tricolor', 4.5, 'Activo', 'Muy dócil', 10),
('Cooper', 'Perro', 'Beagle', 'M', '2021-10-03', 'Tricolor', 12.0, 'Activo', 'Cazador nato', 1),
('Princess', 'Gato', 'Angora', 'H', '2022-04-20', 'Blanco', 3.5, 'Activo', 'Muy elegante', 2);

-- ============================================
-- INSERTAR PRODUCTOS
-- ============================================
INSERT INTO Producto (Nombre, Tipo, Precio, Costo, Descripcion, Unidad_Medida, Categoria, ID_Proveedor) VALUES 
('Alimento Premium Perros', 'Alimento', 85.50, 60.00, 'Alimento balanceado para perros adultos', 'Kg', 'Alimentación', 1),
('Vacuna Triple Canina', 'Medicamento', 45.00, 30.00, 'Vacuna contra moquillo, hepatitis y parvovirus', 'Dosis', 'Medicina', 2),
('Collar Antipulgas', 'Accesorio', 25.90, 15.00, 'Collar repelente de pulgas y garrapatas', 'Unidad', 'Higiene', 3),
('Shampoo Medicado', 'Higiene', 32.00, 20.00, 'Shampoo para problemas dermatológicos', 'Ml', 'Higiene', 4),
('Alimento Gatos Esterilizados', 'Alimento', 78.00, 55.00, 'Alimento especializado para gatos esterilizados', 'Kg', 'Alimentación', 5),
('Antibiótico Amoxicilina', 'Medicamento', 18.50, 12.00, 'Antibiótico de amplio espectro', 'Ml', 'Medicina', 6),
('Juguete Masticable', 'Juguete', 15.00, 8.00, 'Hueso sintético para masticar', 'Unidad', 'Juguetes', 7),
('Arena para Gatos', 'Higiene', 22.50, 14.00, 'Arena sanitaria absorbente', 'Kg', 'Higiene', 8),
('Vitaminas Múltiples', 'Suplemento', 35.75, 22.00, 'Complejo vitamínico para mascotas', 'Ml', 'Medicina', 1),
('Correa Ajustable', 'Accesorio', 28.00, 18.00, 'Correa resistente ajustable', 'Unidad', 'Accesorios', 2);

-- ============================================
-- INSERTAR SERVICIOS ADICIONALES
-- ============================================
INSERT INTO Servicio_Adicional (Nombre, Precio, Costo, Descripcion, Duracion_Minutos, Categoria) VALUES 
('Baño y Corte', 35.00, 18.00, 'Servicio completo de aseo personal', 60, 'Estética'),
('Desparasitación Externa', 25.00, 12.00, 'Tratamiento contra pulgas y garrapatas', 20, 'Medicina'),
('Limpieza Dental', 80.00, 45.00, 'Profilaxis dental profesional', 45, 'Odontología'),
('Microchip', 60.00, 35.00, 'Implantación de microchip identificatorio', 15, 'Identificación'),
('Radiografía', 150.00, 80.00, 'Estudio radiológico completo', 30, 'Diagnóstico'),
('Análisis de Sangre', 120.00, 70.00, 'Hemograma completo', 15, 'Diagnóstico');

-- ============================================
-- INSERTAR CITAS
-- ============================================
INSERT INTO Cita (Fecha, Hora, Motivo, Estado, Observacion, Costo, Duracion_Minutos, ID_Mascota, ID_Veterinario, ID_Sede) VALUES 
('2024-03-15', '09:00:00', 'Control rutinario', 'Completada', 'Mascota en buen estado', 50.00, 30, 1, 1, 1),
('2024-03-16', '10:30:00', 'Vacunación', 'Completada', 'Vacuna aplicada correctamente', 45.00, 20, 2, 2, 2),
('2024-03-17', '14:00:00', 'Consulta por alergia', 'Completada', 'Tratamiento prescrito', 75.00, 45, 3, 3, 3),
('2024-03-18', '11:15:00', 'Revisión cardíaca', 'Completada', 'Corazón funcionando bien', 120.00, 60, 4, 4, 4),
('2024-03-19', '15:45:00', 'Cirugía menor', 'Completada', 'Operación exitosa', 300.00, 120, 5, 5, 5),
('2024-03-20', '08:30:00', 'Consulta neurológica', 'Completada', 'Sin anomalías detectadas', 150.00, 60, 6, 6, 6),
('2024-03-21', '16:00:00', 'Control post-operatorio', 'Completada', 'Recuperación satisfactoria', 60.00, 30, 7, 7, 7),
('2024-03-22', '13:30:00', 'Consulta pediátrica', 'Completada', 'Cachorro saludable', 55.00, 30, 8, 8, 8);

-- ============================================
-- INSERTAR VENTAS
-- ============================================
INSERT INTO Venta (Fecha, Total, Tipo_Pago, Estado, ID_Cliente, ID_Sede, Descuento) VALUES 
('2024-03-15 10:30:00', 171.00, 'Efectivo', 'Completada', 1, 1, 0),
('2024-03-16 11:45:00', 123.90, 'Tarjeta', 'Completada', 2, 2, 0),
('2024-03-17 15:20:00', 96.00, 'Transferencia', 'Completada', 3, 3, 0),
('2024-03-18 12:00:00', 156.00, 'Efectivo', 'Completada', 4, 4, 0),
('2024-03-19 16:30:00', 78.00, 'Tarjeta', 'Completada', 5, 5, 0),
('2024-03-20 09:15:00', 67.50, 'Efectivo', 'Completada', 6, 6, 0);

-- ============================================
-- INSERTAR DETALLE VENTAS
-- ============================================
INSERT INTO DetalleVenta (ID_Venta, ID_Producto, Cantidad, Precio_Unitario, Subtotal) VALUES 
(1, 1, 2, 85.50, 171.00),
(2, 2, 1, 45.00, 45.00),
(2, 3, 3, 25.90, 77.70),
(3, 4, 3, 32.00, 96.00),
(4, 5, 2, 78.00, 156.00),
(5, 6, 1, 18.50, 18.50),
(5, 7, 4, 15.00, 60.00),
(6, 8, 3, 22.50, 67.50);

-- ============================================
-- INSERTAR DETALLE SERVICIOS
-- ============================================
INSERT INTO DetalleServicio (ID_Venta, ID_Servicio_Adicional, Cantidad, Precio_Unitario, Subtotal) VALUES 
(1, 1, 1, 35.00, 35.00),
(2, 2, 1, 25.00, 25.00),
(3, 3, 1, 80.00, 80.00),
(4, 4, 1, 60.00, 60.00),
(5, 5, 1, 150.00, 150.00);

-- ============================================
-- INSERTAR STOCK
-- ============================================
INSERT INTO Stock_Producto (ID_Sede, ID_Producto, Cantidad_Disponible, Stock_Minimo, Stock_Maximo) VALUES 
(1, 1, 50, 10, 100),
(1, 2, 25, 5, 50),
(2, 3, 30, 8, 60),
(2, 4, 15, 3, 40),
(3, 5, 40, 8, 80),
(3, 6, 20, 5, 50),
(4, 7, 35, 10, 70),
(4, 8, 60, 15, 100),
(5, 9, 12, 3, 30),
(5, 10, 25, 5, 50);

-- ============================================
-- INSERTAR COMPRAS
-- ============================================
INSERT INTO Compra (Fecha, Total, Estado, ID_Sede) VALUES 
('2024-03-10 10:00:00', 2500.00, 'Completada', 1),
('2024-03-11 14:30:00', 1800.00, 'Completada', 2),
('2024-03-12 09:15:00', 3200.00, 'Completada', 3),
('2024-03-13 16:45:00', 1950.00, 'Completada', 4),
('2024-03-14 11:20:00', 2750.00, 'Completada', 5);

-- ============================================
-- INSERTAR DETALLE COMPRAS
-- ============================================
INSERT INTO DetalleCompra (ID_Compra, ID_Producto, ID_Proveedor, Cantidad, Precio_Unitario, Subtotal) VALUES 
(1, 1, 1, 30, 60.00, 1800.00),
(2, 2, 2, 40, 30.00, 1200.00),
(3, 3, 3, 50, 15.00, 750.00),
(3, 4, 4, 60, 20.00, 1200.00),
(4, 5, 5, 25, 55.00, 1375.00),
(5, 6, 6, 35, 12.00, 420.00);

-- ============================================
-- INSERTAR TRATAMIENTOS
-- ============================================
INSERT INTO Tratamiento (Descripcion, Medicamento, Dosis, Frecuencia, Duracion, Fecha_Inicio, Fecha_Fin, Estado, Costo, ID_Cita) VALUES 
('Tratamiento antibiótico por infección', 'Amoxicilina', '250mg', 'Cada 12 horas', '7 días', '2024-03-17 14:30:00', '2024-03-24 14:30:00', 'Completado', 75.00, 3),
('Medicación cardíaca', 'Enalapril', '5mg', 'Una vez al día', '30 días', '2024-03-18 11:45:00', '2024-04-17 11:45:00', 'En Progreso', 120.00, 4),
('Analgésicos post-cirugía', 'Meloxicam', '1.5mg', 'Cada 24 horas', '5 días', '2024-03-19 16:15:00', '2024-03-24 16:15:00', 'Completado', 45.00, 5),
('Antiinflamatorio', 'Prednisona', '10mg', 'Cada 12 horas', '10 días', '2024-03-20 09:00:00', '2024-03-30 09:00:00', 'En Progreso', 65.00, 6),
('Cicatrizante tópico', 'Pomada antibiótica', 'Aplicar', '2 veces al día', '14 días', '2024-03-21 16:30:00', '2024-04-04 16:30:00', 'En Progreso', 35.00, 7),
('Suplemento vitamínico', 'Multivitamínico', '5ml', 'Una vez al día', '21 días', '2024-03-22 14:00:00', '2024-04-12 14:00:00', 'En Progreso', 55.00, 8),
('Desparasitante interno', 'Praziquantel', '50mg', 'Dosis única', '3 días', '2024-03-15 09:30:00', '2024-03-18 09:30:00', 'Completado', 25.00, 1);

-- ============================================
-- INSERTAR VACUNAS
-- ============================================
INSERT INTO Vacuna (Nombre, Dosis, Lote, Fecha_Aplicacion, Fecha_Proxima, Costo, ID_Mascota, ID_Veterinario) VALUES 
('Triple Canina', '1ml', 'LOT2024A', '2024-01-15 10:00:00', '2025-01-15 10:00:00', 45.00, 1, 1),
('Triple Felina', '0.5ml', 'LOT2024B', '2024-02-10 11:30:00', '2025-02-10 11:30:00', 40.00, 2, 2),
('Antirrábica', '1ml', 'LOT2024C', '2024-01-20 14:00:00', '2025-01-20 14:00:00', 35.00, 3, 3),
('Leucemia Felina', '1ml', 'LOT2024D', '2024-03-05 09:15:00', '2025-03-05 09:15:00', 50.00, 4, 4),
('Parvovirus', '1ml', 'LOT2024E', '2024-02-28 16:45:00', '2025-02-28 16:45:00', 45.00, 5, 5),
('Rinotraqueitis', '0.5ml', 'LOT2024F', '2024-01-30 08:30:00', '2025-01-30 08:30:00', 40.00, 6, 6),
('Bordetella', '0.5ml', 'LOT2024G', '2024-03-10 13:20:00', '2025-03-10 13:20:00', 38.00, 7, 7),
('Calicivirus', '0.5ml', 'LOT2024H', '2024-02-15 15:10:00', '2025-02-15 15:10:00', 40.00, 8, 8);

-- ============================================
-- INSERTAR EXÁMENES
-- ============================================
INSERT INTO Examen (Tipo, Resultado, Fecha, Costo, ID_Veterinario, ID_Mascota) VALUES 
('Hemograma', 'Valores normales - Leucocitos: 8.5k, Hemoglobina: 15.2g/dl', '2024-03-15 10:30:00', 120.00, 1, 1),
('Radiografía Torácica', 'Sin anomalías en campos pulmonares', '2024-03-16 14:15:00', 150.00, 2, 2),
('Análisis de Orina', 'Infección urinaria leve - pH: 7.2, Leucocitos presentes', '2024-03-17 11:45:00', 80.00, 3, 3),
('Ecocardiograma', 'Función cardíaca normal - Fracción de eyección: 65%', '2024-03-18 09:20:00', 200.00, 4, 4),
('Biopsia', 'Tumor benigno - Lipoma de 2cm', '2024-03-19 16:30:00', 250.00, 5, 5),
('Electroencefalograma', 'Actividad cerebral normal - Sin ondas epilépticas', '2024-03-20 13:00:00', 300.00, 6, 6);

-- ============================================
-- INSERTAR HISTORIAL MÉDICO
-- ============================================
INSERT INTO Historial_Medico (Fecha, Sintomas, Diagnostico, Recomendacion, Observacion, Peso_Kg, Temperatura, ID_Veterinario, ID_Mascota, ID_Cita) VALUES 
('2024-03-15 09:30:00', 'Letargo leve y pérdida de apetito', 'Estado general bueno', 'Continuar con dieta balanceada y ejercicio regular', 'Control en 6 meses', 28.5, 38.5, 1, 1, 1),
('2024-03-16 10:45:00', 'Ninguno', 'Salud óptima', 'Mantener vacunaciones al día', 'Próximo control en 1 año', 4.2, 38.3, 2, 2, 2),
('2024-03-17 14:15:00', 'Picazón intensa y enrojecimiento en piel', 'Dermatitis alérgica', 'Cambiar dieta a hipoalergénica y aplicar medicación tópica', 'Evitar alérgenos identificados (pollo)', 35.0, 38.7, 3, 3, 3),
('2024-03-18 11:30:00', 'Soplo cardíaco detectado', 'Insuficiencia mitral leve - Grado II', 'Medicación cardíaca diaria', 'Control ecocardiográfico cada 3 meses', 3.8, 38.2, 4, 4, 4),
('2024-03-19 16:00:00', 'Masa palpable en abdomen', 'Lipoma benigno de 3cm', 'Cirugía de extirpación programada', 'Post-operatorio favorable, retiro de puntos en 10 días', 30.2, 38.4, 5, 5, 5),
('2024-03-20 08:45:00', 'Convulsiones ocasionales (2 en último mes)', 'Epilepsia idiopática', 'Iniciar medicación anticonvulsiva', 'Monitoreo neurológico mensual', 5.5, 38.6, 6, 6, 6),
('2024-03-21 16:15:00', 'Cojera en pata trasera derecha', 'Luxación de rótula grado II', 'Fisioterapia 3 veces por semana', 'Cirugía si empeora o no mejora en 2 meses', 45.0, 38.5, 7, 7, 7),
('2024-03-22 13:45:00', 'Diarrea leve y vómitos ocasionales', 'Parasitosis intestinal - Giardias detectadas', 'Desparasitante específico y dieta blanda', 'Dieta blanda por 3 días, control de heces', 25.0, 38.8, 8, 8, 8);

-- ============================================
-- VERIFICACIÓN DE DATOS
-- ============================================

-- Contar registros insertados
SELECT 'Sedes' AS Tabla, COUNT(*) AS Total FROM Sede
UNION ALL
SELECT 'Proveedores', COUNT(*) FROM Proveedor
UNION ALL
SELECT 'Clientes', COUNT(*) FROM Cliente
UNION ALL
SELECT 'Veterinarios', COUNT(*) FROM Veterinario
UNION ALL
SELECT 'Mascotas', COUNT(*) FROM Mascota
UNION ALL
SELECT 'Productos', COUNT(*) FROM Producto
UNION ALL
SELECT 'Servicios', COUNT(*) FROM Servicio_Adicional
UNION ALL
SELECT 'Citas', COUNT(*) FROM Cita
UNION ALL
SELECT 'Ventas', COUNT(*) FROM Venta
UNION ALL
SELECT 'Tratamientos', COUNT(*) FROM Tratamiento
UNION ALL
SELECT 'Vacunas', COUNT(*) FROM Vacuna
UNION ALL
SELECT 'Exámenes', COUNT(*) FROM Examen
UNION ALL
SELECT 'Historial Médico', COUNT(*) FROM Historial_Medico;


-- ============================================

select * from sede;