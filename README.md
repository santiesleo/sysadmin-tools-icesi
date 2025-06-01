# Sysadmin Tools Icesi

## Integrantes
- Juan David Colonia
- Juan Manuel Díaz
- Santiago Escobar León

## Requerimientos del Proyecto
- Python 3.12 o superior
- pip (gestor de paquetes de Python)
- Acceso a terminal con permisos de administrador
- Conexión a internet para la instalación de dependencias

## Requerimientos Funcionales
1. **Monitoreo de Procesos**
   - Visualización de los 5 procesos que más CPU consumen
   - Capacidad para terminar procesos seleccionados
   - Actualización automática de la información cada 5 segundos

2. **Gestión de Memoria**
   - Visualización del uso total de memoria RAM
   - Monitoreo de memoria disponible
   - Porcentaje de uso de memoria

3. **Monitoreo de Discos**
   - Visualización de espacio total en disco
   - Espacio disponible en cada unidad
   - Porcentaje de uso de cada disco
   - Identificación del archivo más grande en un directorio especificado

4. **Monitoreo de Red**
   - Visualización de conexiones de red establecidas
   - Información de puertos y direcciones IP
   - Estado de las conexiones

5. **Interfaz de Usuario**
   - Interfaz web accesible mediante navegador
   - Diseño responsivo y moderno
   - Historial de operaciones realizadas
   - Mensajes de confirmación y error
   - Actualización en tiempo real de la información

6. **Seguridad**
   - Validación de permisos de administrador
   - Protección contra operaciones no autorizadas
   - Registro de acciones realizadas

## Instalación y Ejecución

### Windows
1. Asegúrate de tener Python 3.12 instalado
2. Abre PowerShell como administrador
3. Navega al directorio del proyecto
4. Crea un entorno virtual:
   ```powershell
   python -m venv venv
   ```
5. Activa el entorno virtual:
   ```powershell
   .\venv\Scripts\activate
   ```
6. Instala las dependencias:
   ```powershell
   pip install -r requirements.txt
   ```
7. Ejecuta la aplicación:
   ```powershell
   python app.py
   ```

### Linux
1. Abre una terminal
2. Navega al directorio del proyecto
3. Dale permisos de ejecución al script:
   ```bash
   chmod +x linux_monitor/app.sh
   ```
4. Instala Python 3.12:
   ```bash
   sudo apt install python3.12
   ```
5. Crea un entorno virtual:
   ```bash
   python3 -m venv nombre_del_entorno
   ```
6. Activa el entorno virtual:
   ```bash
   source nombre_del_entorno/bin/activate
   ```
7. Instala las dependencias:
   ```bash
   pip install -r requirements.txt
   ```
8. Ejecuta la aplicación:
   ```bash
   python3 app.py
   ```

## Notas
- Asegúrate de tener todos los permisos necesarios antes de ejecutar la aplicación
- En Linux, algunos comandos pueden requerir permisos de superusuario (sudo)
- La aplicación debe ejecutarse en un entorno con acceso a los recursos del sistema 
