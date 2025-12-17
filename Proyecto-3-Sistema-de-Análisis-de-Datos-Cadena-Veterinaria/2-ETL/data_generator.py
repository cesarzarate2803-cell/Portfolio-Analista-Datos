"""
============================================
GENERADOR DE DATOS MASIVOS - VETERINARIA
============================================
Genera 100,000+ registros realistas para el proyecto
Requiere: pip install faker psycopg2-binary pandas --break-system-packages
"""

import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
import sys

# Configuración
fake = Faker('es_ES')  # Datos en español
Faker.seed(42)  # Para reproducibilidad

# ============================================
# CONFIGURACIÓN DE CONEXIÓN
# ============================================
DB_CONFIG = {
    'host': 'localhost',
    'database': 'db_veterinaria',
    'user': 'postgres',
    'password': 'postadmin',
    'port': 5432
}

# ============================================
# VOLUMEN DE DATOS A GENERAR
# ============================================
CANTIDAD = {
    'clientes': 10000,
    'mascotas': 15000,
    'veterinarios': 30,
    'productos': 500,
    'servicios': 20,
    'citas': 80000,
    'ventas': 50000,
    'tratamientos': 40000,
    'vacunas': 30000,
    'examenes': 25000,
    'historial': 60000
}

# ============================================
# DATOS DE REFERENCIA
# ============================================
ESPECIES = ['Perro', 'Gato']
RAZAS_PERRO = [
    'Golden Retriever', 'Labrador', 'Pastor Alemán', 'Bulldog', 'Beagle',
    'Poodle', 'Chihuahua', 'Yorkshire', 'Rottweiler', 'Dachshund',
    'Boxer', 'Husky Siberiano', 'Schnauzer', 'Cocker Spaniel', 'Mestizo'
]
RAZAS_GATO = [
    'Persa', 'Siamés', 'Maine Coon', 'Bengalí', 'Ragdoll',
    'British Shorthair', 'Sphynx', 'Angora', 'Scottish Fold', 'Mestizo'
]

COLORES = ['Negro', 'Blanco', 'Marrón', 'Gris', 'Dorado', 'Tricolor', 'Atigrado', 'Manchado']
SEXOS = ['M', 'H']

ESPECIALIDADES_VET = [
    'Medicina General', 'Cirugía', 'Dermatología', 'Cardiología',
    'Oncología', 'Neurología', 'Oftalmología', 'Traumatología',
    'Odontología', 'Medicina Interna', 'Pediatría Veterinaria'
]

MOTIVOS_CITA = [
    'Control rutinario', 'Vacunación', 'Consulta por enfermedad',
    'Revisión post-operatoria', 'Emergencia', 'Chequeo geriátrico',
    'Consulta dermatológica', 'Problemas digestivos', 'Cojera',
    'Consulta por alergia', 'Castración/Esterilización'
]

ESTADOS_CITA = ['Completada', 'Programada', 'Cancelada', 'No Asistió']

CATEGORIAS_PRODUCTO = ['Alimentación', 'Medicina', 'Higiene', 'Juguetes', 'Accesorios']
TIPOS_PAGO = ['Efectivo', 'Tarjeta', 'Transferencia', 'Yape', 'Plin']

NOMBRES_VACUNA = [
    'Triple Canina', 'Antirrábica', 'Parvovirus', 'Bordetella',
    'Triple Felina', 'Leucemia Felina', 'Rinotraqueitis', 'Calicivirus'
]

TIPOS_EXAMEN = [
    'Hemograma', 'Análisis de Orina', 'Radiografía', 'Ecografía',
    'Ecocardiograma', 'Biopsia', 'Electrocardiograma', 'Coprocultivo'
]

# ============================================
# FUNCIONES AUXILIARES
# ============================================

def conectar_db():
    """Conecta a PostgreSQL"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print(" Conexión exitosa a PostgreSQL")
        return conn
    except Exception as e:
        print(f" Error de conexión: {e}")
        sys.exit(1)

def obtener_ids_existentes(cursor, tabla, columna_id):
    """Obtiene IDs existentes de una tabla"""
    cursor.execute(f"SELECT {columna_id} FROM {tabla}")
    return [row[0] for row in cursor.fetchall()]

def fecha_aleatoria(inicio, fin):
    """Genera fecha aleatoria entre dos fechas"""
    delta = fin - inicio
    random_days = random.randint(0, delta.days)
    return inicio + timedelta(days=random_days)

def hora_aleatoria():
    """Genera hora de trabajo aleatoria (8am-6pm)"""
    hora = random.randint(8, 18)
    minuto = random.choice([0, 15, 30, 45])
    return f"{hora:02d}:{minuto:02d}:00"

# ============================================
# GENERADORES DE DATOS
# ============================================

def generar_clientes(cursor, cantidad):
    """Genera clientes"""
    print(f"\n Generando {cantidad:,} clientes...")
    
    clientes = []
    dnis_usados = set()
    emails_usados = set()
    
    for i in range(cantidad):
        dni = str(random.randint(10000000, 99999999))
        while dni in dnis_usados:
            dni = str(random.randint(10000000, 99999999))
        dnis_usados.add(dni)
        
        nombre = fake.first_name()
        apellido = fake.last_name()
        email = f"{nombre.lower()}.{apellido.lower()}{random.randint(1,999)}@email.com"
        
        while email in emails_usados:
            email = f"{nombre.lower()}.{apellido.lower()}{random.randint(1,9999)}@email.com"
        emails_usados.add(email)
        
        fecha_registro = fecha_aleatoria(
            datetime(2020, 1, 1),
            datetime(2024, 12, 1)
        )
        
        clientes.append((
            nombre,
            apellido,
            fake.phone_number()[:15],
            fake.address()[:100],
            email,
            dni,
            fecha_registro,
            random.choice(['Activo', 'Activo', 'Activo', 'Inactivo'])  # 75% activos
        ))
        
        if (i + 1) % 1000 == 0:
            print(f"  Progreso: {i+1:,}/{cantidad:,}")
    
    cursor.executemany("""
        INSERT INTO Cliente (Nombre, Apellido, Telefono, Direccion, Correo_Electronico, 
                            Dni, Fecha_Registro, Estado)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, clientes)
    
    print(f" {cantidad:,} clientes insertados")

def generar_mascotas(cursor, cantidad, ids_clientes):
    """Genera mascotas"""
    print(f"\n Generando {cantidad:,} mascotas...")
    
    nombres_mascota = [
        'Max', 'Luna', 'Rocky', 'Bella', 'Charlie', 'Lucy', 'Cooper', 'Daisy',
        'Buddy', 'Molly', 'Zeus', 'Chloe', 'Duke', 'Lola', 'Bear', 'Lily',
        'Oliver', 'Mia', 'Teddy', 'Sophie', 'Jack', 'Sadie', 'Toby', 'Maggie'
    ]
    
    mascotas = []
    for i in range(cantidad):
        especie = random.choice(ESPECIES)
        raza = random.choice(RAZAS_PERRO if especie == 'Perro' else RAZAS_GATO)
        
        fecha_nac = fecha_aleatoria(
            datetime(2015, 1, 1),
            datetime(2024, 6, 1)
        )
        
        peso = round(random.uniform(2.0, 45.0), 2) if especie == 'Perro' else round(random.uniform(2.0, 8.0), 2)
        
        mascotas.append((
            random.choice(nombres_mascota),
            especie,
            raza,
            random.choice(SEXOS),
            fecha_nac,
            random.choice(COLORES),
            peso,
            random.choice(['Activo', 'Activo', 'Activo', 'Fallecido']),  # 75% activos
            fake.sentence() if random.random() > 0.7 else None,
            random.choice(ids_clientes)
        ))
        
        if (i + 1) % 1000 == 0:
            print(f"  Progreso: {i+1:,}/{cantidad:,}")
    
    cursor.executemany("""
        INSERT INTO Mascota (Nombre, Especie, Raza, Sexo, Fecha_Nacimiento, Color,
                            Peso_Kg, Estado, Observacion, ID_Cliente)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, mascotas)
    
    print(f" {cantidad:,} mascotas insertadas")

def generar_veterinarios(cursor, cantidad, ids_sedes):
    """Genera veterinarios"""
    print(f"\n Generando {cantidad} veterinarios...")
    
    veterinarios = []
    dnis_usados = set()
    colegiaturas_usadas = set()
    
    for i in range(cantidad):
        dni = str(random.randint(20000000, 29999999))
        while dni in dnis_usados:
            dni = str(random.randint(20000000, 29999999))
        dnis_usados.add(dni)
        
        colegiatura = f"VET{random.randint(1000, 9999)}"
        while colegiatura in colegiaturas_usadas:
            colegiatura = f"VET{random.randint(1000, 9999)}"
        colegiaturas_usadas.add(colegiatura)
        
        nombre = fake.first_name()
        apellido = fake.last_name()
        
        veterinarios.append((
            nombre,
            apellido,
            random.choice(ESPECIALIDADES_VET),
            fake.phone_number()[:15],
            f"{nombre.lower()}.{apellido.lower()}@vetclinic.com",
            dni,
            colegiatura,
            random.choice(ids_sedes),
            fecha_aleatoria(datetime(2015, 1, 1), datetime(2024, 1, 1))
        ))
    
    cursor.executemany("""
        INSERT INTO Veterinario (Nombre, Apellido, Especialidad, Telefono, 
                                Correo_Electronico, Dni, Colegiatura, ID_Sede, Fecha_Contratacion)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, veterinarios)
    
    print(f" {cantidad} veterinarios insertados")

def generar_productos(cursor, cantidad, ids_proveedores):
    """Genera productos"""
    print(f"\n Generando {cantidad} productos...")
    
    productos = []
    for i in range(cantidad):
        categoria = random.choice(CATEGORIAS_PRODUCTO)
        precio = round(random.uniform(10.0, 500.0), 2)
        costo = round(precio * random.uniform(0.5, 0.75), 2)
        
        productos.append((
            fake.word().capitalize() + " " + categoria,
            categoria,
            precio,
            costo,
            fake.sentence(),
            random.choice(['Kg', 'Unidad', 'Ml', 'Gr']),
            categoria,
            random.choice(ids_proveedores)
        ))
    
    cursor.executemany("""
        INSERT INTO Producto (Nombre, Tipo, Precio, Costo, Descripcion, 
                             Unidad_Medida, Categoria, ID_Proveedor)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, productos)
    
    print(f" {cantidad} productos insertados")

def generar_citas(cursor, cantidad, ids_mascotas, ids_veterinarios, ids_sedes):
    """Genera citas"""
    print(f"\n Generando {cantidad:,} citas...")
    
    citas = []
    for i in range(cantidad):
        fecha = fecha_aleatoria(datetime(2022, 1, 1), datetime(2024, 12, 10))
        estado = random.choice(ESTADOS_CITA)
        
        # Pesos según realismo: más completadas que programadas
        if random.random() < 0.7:
            estado = 'Completada'
        
        citas.append((
            fecha.date(),
            hora_aleatoria(),
            random.choice(MOTIVOS_CITA),
            estado,
            fake.sentence() if random.random() > 0.6 else None,
            round(random.uniform(30.0, 500.0), 2),
            random.choice([30, 45, 60, 90, 120]),
            random.choice(ids_mascotas),
            random.choice(ids_veterinarios),
            random.choice(ids_sedes),
            fecha
        ))
        
        if (i + 1) % 5000 == 0:
            print(f"  Progreso: {i+1:,}/{cantidad:,}")
    
    cursor.executemany("""
        INSERT INTO Cita (Fecha, Hora, Motivo, Estado, Observacion, Costo,
                         Duracion_Minutos, ID_Mascota, ID_Veterinario, ID_Sede, Fecha_Creacion)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, citas)
    
    print(f" {cantidad:,} citas insertadas")

def generar_ventas(cursor, cantidad, ids_clientes, ids_sedes, ids_productos, ids_servicios):
    """Genera ventas con detalles"""
    print(f"\n Generando {cantidad:,} ventas...")
    
    for i in range(cantidad):
        fecha = fecha_aleatoria(datetime(2022, 1, 1), datetime(2024, 12, 10))
        id_cliente = random.choice(ids_clientes)
        id_sede = random.choice(ids_sedes)
        tipo_pago = random.choice(TIPOS_PAGO)
        
        # Insertar venta
        cursor.execute("""
            INSERT INTO Venta (Fecha, Total, Tipo_Pago, Estado, ID_Cliente, ID_Sede)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING ID_Venta
        """, (fecha, 0, tipo_pago, 'Completada', id_cliente, id_sede))
        
        id_venta = cursor.fetchone()[0]
        
        # Generar detalles de productos (1-5 productos por venta)
        total = 0
        num_productos = random.randint(1, 5)
        
        for _ in range(num_productos):
            id_producto = random.choice(ids_productos)
            cursor.execute("SELECT Precio FROM Producto WHERE ID_Producto = %s", (id_producto,))
            precio = cursor.fetchone()[0]
            
            cantidad = random.randint(1, 5)
            subtotal = precio * cantidad
            total += subtotal
            
            cursor.execute("""
                INSERT INTO DetalleVenta (ID_Venta, ID_Producto, Cantidad, Precio_Unitario, Subtotal)
                VALUES (%s, %s, %s, %s, %s)
            """, (id_venta, id_producto, cantidad, precio, subtotal))
        
        # Agregar servicios ocasionalmente (30% de las ventas)
        if random.random() < 0.3:
            id_servicio = random.choice(ids_servicios)
            cursor.execute("SELECT Precio FROM Servicio_Adicional WHERE ID_Servicio_Adicional = %s", (id_servicio,))
            precio_servicio = cursor.fetchone()[0]
            
            total += precio_servicio
            
            cursor.execute("""
                INSERT INTO DetalleServicio (ID_Venta, ID_Servicio_Adicional, Cantidad, Precio_Unitario, Subtotal)
                VALUES (%s, %s, %s, %s, %s)
            """, (id_venta, id_servicio, 1, precio_servicio, precio_servicio))
        
        # Actualizar total de venta
        cursor.execute("UPDATE Venta SET Total = %s WHERE ID_Venta = %s", (total, id_venta))
        
        if (i + 1) % 1000 == 0:
            print(f"  Progreso: {i+1:,}/{cantidad:,}")
    
    print(f" {cantidad:,} ventas insertadas")

# ============================================
# FUNCIÓN PRINCIPAL
# ============================================

def main():
    print("""
    ═══════════════════════════════════════════
    GENERADOR DE DATOS MASIVOS - VETERINARIA
    ═══════════════════════════════════════════
    """)
    
    # Conectar
    conn = conectar_db()
    cursor = conn.cursor()
    
    try:
        # Obtener IDs existentes
        print("\n Obteniendo IDs existentes...")
        ids_sedes = obtener_ids_existentes(cursor, 'Sede', 'ID_Sede')
        ids_proveedores = obtener_ids_existentes(cursor, 'Proveedor', 'ID_Proveedor')
        
        print(f"  - {len(ids_sedes)} sedes encontradas")
        print(f"  - {len(ids_proveedores)} proveedores encontrados")
        
        # Generar datos
        generar_clientes(cursor, CANTIDAD['clientes'])
        conn.commit()
        
        ids_clientes = obtener_ids_existentes(cursor, 'Cliente', 'ID_Cliente')
        
        generar_mascotas(cursor, CANTIDAD['mascotas'], ids_clientes)
        conn.commit()
        
        ids_mascotas = obtener_ids_existentes(cursor, 'Mascota', 'ID_Mascota')
        
        generar_veterinarios(cursor, CANTIDAD['veterinarios'], ids_sedes)
        conn.commit()
        
        ids_veterinarios = obtener_ids_existentes(cursor, 'Veterinario', 'ID_Veterinario')
        
        generar_productos(cursor, CANTIDAD['productos'], ids_proveedores)
        conn.commit()
        
        ids_productos = obtener_ids_existentes(cursor, 'Producto', 'ID_Producto')
        ids_servicios = obtener_ids_existentes(cursor, 'Servicio_Adicional', 'ID_Servicio_Adicional')
        
        generar_citas(cursor, CANTIDAD['citas'], ids_mascotas, ids_veterinarios, ids_sedes)
        conn.commit()
        
        generar_ventas(cursor, CANTIDAD['ventas'], ids_clientes, ids_sedes, ids_productos, ids_servicios)
        conn.commit()
        
        print("\n" + "="*50)
        print(" GENERACIÓN COMPLETADA EXITOSAMENTE ")
        print("="*50)
        
        # Resumen final
        print("\n RESUMEN FINAL:")
        tablas = [
            'Cliente', 'Mascota', 'Veterinario', 'Producto', 
            'Cita', 'Venta', 'DetalleVenta'
        ]
        
        for tabla in tablas:
            cursor.execute(f"SELECT COUNT(*) FROM {tabla}")
            count = cursor.fetchone()[0]
            print(f"  {tabla}: {count:,} registros")
        
    except Exception as e:
        conn.rollback()
        print(f"\n ERROR: {e}")
        raise
    
    finally:
        cursor.close()
        conn.close()
        print("\n Conexión cerrada")

if __name__ == "__main__":
    main()
