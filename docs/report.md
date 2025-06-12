# Sistema de Monitoreo Multiplataforma

## Descripción General

Este proyecto es un **dashboard web de monitoreo del sistema** que funciona tanto en **Windows** como en **Linux**. Proporciona información en tiempo real sobre el uso de recursos del sistema (CPU, memoria, disco, red) a través de una interfaz web moderna.

### Arquitectura del Sistema

```
┌─────────────────┐    HTTP     ┌─────────────────┐    subprocess    ┌──────────────────┐
│   Frontend      │ ──────────► │   Flask API     │ ───────────────► │ Scripts Sistema  │
│   (HTML/JS)     │             │   (Python)      │                  │ (Bash/PowerShell)│
└─────────────────┘             └─────────────────┘                  └──────────────────┘
```

**Componentes principales:**
- **Frontend**: SPA (Single Page Application) con HTML, CSS y JavaScript
- **Backend**: API REST desarrollada en Flask (Python)
- **Scripts de Sistema**: Bash para Linux, PowerShell para Windows
- **Detección automática**: Adapta automáticamente el comportamiento según el SO

---

## Estructura del Proyecto

```
sistema-monitoreo/
├── app.py                      # Servidor Flask (API REST)
├── templates/
│   └── index.html             # Frontend (SPA)
├── linux_monitor/
│   └── app.sh                # Script Bash para Linux
└── windows_monitor/
    └── app.ps1               # Script PowerShell para Windows
```

---

## Componente 1: Scripts de Sistema

### Script Bash (Linux) - `linux_monitor/app.sh`

**Propósito**: Recopila información del sistema usando herramientas nativas de Linux.

#### Funciones principales:

**`get_top_processes()`**
- Obtiene los 5 procesos que más CPU consumen
- Comando: `ps aux --sort=-%cpu | head -n 6 | tail -n 5`
- Salida: Tabla HTML con PID, nombre y porcentaje de CPU

**`get_disk_info()`**
- Información de sistemas de archivos montados
- Comando: `df -B1` (información en bytes)
- Salida: Tabla con filesystem, tamaño total, espacio libre y porcentaje

**`get_largest_file()`**
- Encuentra el archivo más grande en un directorio
- Comando: `find $path -type f -exec du -b {} \; | sort -nr | head -n 1`
- Parámetro: Ruta del directorio a analizar

**`get_memory_info()`**
- Información de memoria RAM y swap
- Comando: `free -b` (información en bytes)
- Calcula porcentajes de memoria libre

**`get_network_connections()`**
- Conexiones TCP establecidas
- Comando: `netstat -tnp | grep ESTABLISHED`
- Muestra puertos locales, remotos, estado y PID

**Uso del script:**
```bash
./app.sh get_top_processes
./app.sh get_disk_info
./app.sh get_largest_file /home/usuario
./app.sh get_memory_info
./app.sh get_network_connections
./app.sh show_menu
```

### Script PowerShell (Windows) - `windows_monitor/app.ps1`

**Propósito**: Equivalente del script Bash pero usando cmdlets nativos de PowerShell.

#### Funciones principales:

**`Get-TopProcesses`**
- Usa: `Get-Process | Sort-Object CPU -Descending`
- Ventaja: Manejo de objetos en lugar de texto plano

**`Get-DiskInfo`**
- Usa: `Get-PSDrive -PSProvider FileSystem`
- Calcula espacio total: `$disk.Used + $disk.Free`

**`Get-LargestFile`**
- Usa: `Get-ChildItem -Recurse -File | Sort-Object Length -Descending`
- Incluye manejo de errores con `try-catch`

**`Get-MemoryInfo`**
- Usa: `Get-CimInstance Win32_OperatingSystem`
- Diferencia entre memoria física y virtual (no swap)

**`Get-NetworkConnections`**
- Usa: `Get-NetTCPConnection -State Established`
- Acceso directo a propiedades del objeto

**Ventajas del enfoque PowerShell:**
- Manejo orientado a objetos
- Mejor manejo de errores (`try-catch`)
- Parámetros tipados
- Código más legible y autodocumentado

**Uso del módulo:**
```powershell
Import-Module .\app.ps1
Get-TopProcesses
Get-DiskInfo
Get-LargestFile -Path "C:\Users"
Get-MemoryInfo
Get-NetworkConnections
```

---

## Componente 2: API REST (Flask)

### Archivo: `app.py`

**Propósito**: Servidor web que actúa como puente entre el frontend y los scripts del sistema.

#### Detección automática de SO

```python
def detect_os():
    system = platform.system()
    if system == "Linux" and "microsoft" in platform.release().lower():
        return "windows"  # WSL detectado
    elif system == "Windows":
        return "windows"
    else:
        return "linux"
```

**Lógica de detección:**
- **Windows nativo**: Usa PowerShell
- **WSL**: Detecta "microsoft" en platform.release() y usa PowerShell  
- **Linux nativo**: Usa Bash

#### Endpoints disponibles

| Endpoint | Método | Descripción | Script Linux | Script Windows |
|----------|--------|-------------|--------------|----------------|
| `/` | GET | Página principal | - | - |
| `/menu` | GET | Menú HTML | `show_menu` | `Show-Menu` |
| `/top-processes` | GET | Top 5 procesos CPU | `get_top_processes` | `Get-TopProcesses` |
| `/disks` | GET | Info de discos | `get_disk_info` | `Get-DiskInfo` |
| `/largest-file` | GET | Archivo más grande | `get_largest_file` | `Get-LargestFile` |
| `/memory` | GET | Info memoria/swap | `get_memory_info` | `Get-MemoryInfo` |
| `/network` | GET | Conexiones de red | `get_network_connections` | `Get-NetworkConnections` |

#### Patrón de ejecución

Cada endpoint sigue este patrón:

```python
@app.route("/endpoint")
def funcion():
    try:
        if OS_TYPE == "windows":
            result = subprocess.run([
                "powershell", "-Command", 
                "& { . ./windows_monitor/app.ps1; Funcion-PowerShell }"
            ], capture_output=True, text=True)
        else:
            result = subprocess.run([
                "bash", "./linux_monitor/app.sh", "funcion_bash"
            ], capture_output=True, text=True)
        
        if result.returncode == 0:
            return result.stdout  # HTML generado
        else:
            return f"Error: {result.stderr}", 500
    except Exception as e:
        return str(e), 500
```

#### Características del servidor

- **Host**: `0.0.0.0` (accesible desde cualquier IP)
- **Puerto**: 8080
- **Formato de respuesta**: HTML (tablas generadas por los scripts)
- **Manejo de errores**: Códigos HTTP 500 + mensaje de error
- **Parámetros**: `/largest-file` acepta `?path=ruta`

---

## Componente 3: Frontend (SPA)

### Archivo: `templates/index.html`

**Propósito**: Interfaz de usuario web que consume la API Flask y presenta la información.

#### Diseño visual

**Tema oscuro moderno:**
- Colores: Fondo #101010, elementos #191919/#2c2c2c
- Tipografía: System fonts (San Francisco, Segoe UI, Roboto)
- Layout: Flexbox responsivo, máximo 1200px
- Efectos: Hover states, transiciones suaves

**Componentes estilizados:**
- Botones con estilo plano y hover effects
- Tablas con bordes sutiles y hover en filas
- Inputs con tema oscuro consistente
- Mensajes de error (rojo) y éxito (verde)

#### Arquitectura JavaScript

**1. Inicialización**
```javascript
fetch('/menu')
  .then(response => response.text())
  .then(html => {
    document.getElementById('menu-container').innerHTML = html;
  });
```

**2. Funciones de navegación**
Cada función sigue este patrón:
```javascript
function showTopProcesses() {
  fetch('/top-processes')
    .then(response => response.text())
    .then(html => {
      document.getElementById('content').innerHTML = 
        '<h2>Top 5 Procesos por CPU</h2>' + html;
    })
    .catch(error => showError('Error: ' + error));
}
```

**3. Funciones disponibles**
- `showTopProcesses()`: Top 5 procesos CPU
- `showDisks()`: Información de discos
- `showLargestFile()`: Archivo más grande (solicita ruta)
- `showMemoryInfo()`: Memoria y swap
- `showNetworkConnections()`: Conexiones de red

**4. Manejo de UX**
- Mensajes de error temporales (5 segundos)
- Prompt nativo para entrada de datos
- Navegación sin recarga de página
- Responsive design

---

## Flujo Completo del Sistema

### Secuencia de operación

1. **Inicialización**
   - Usuario accede a `http://servidor:8080`
   - Flask sirve `index.html`
   - JavaScript carga el menú desde `/menu`

2. **Interacción del usuario**
   - Usuario hace clic en "Top 5 procesos CPU"
   - JavaScript ejecuta `showTopProcesses()`

3. **Procesamiento backend**
   - Flask recibe petición a `/top-processes`
   - Detecta SO (Linux/Windows)
   - Ejecuta script correspondiente:
     - Linux: `bash ./linux_monitor/app.sh get_top_processes`
     - Windows: `powershell -Command "& { . ./windows_monitor/app.ps1; Get-TopProcesses }"`

4. **Generación de datos**
   - Script ejecuta comandos del sistema
   - Procesa la información
   - Genera tabla HTML

5. **Respuesta al frontend**
   - Flask devuelve HTML al JavaScript
   - JavaScript inyecta HTML en `#content`
   - Usuario ve la tabla con datos del sistema

---

## Instalación y Configuración

### Requisitos

**Sistema Linux:**
- Python 3.6+
- Flask
- Bash
- Herramientas: `ps`, `df`, `find`, `free`, `netstat`

**Sistema Windows:**
- Python 3.6+
- Flask
- PowerShell 5.0+
- Permisos para ejecutar scripts PowerShell

### Instalación

1. **Clonar/descargar archivos**
```bash
mkdir sistema-monitoreo
cd sistema-monitoreo
```

2. **Crear estructura de directorios**
```bash
mkdir templates linux_monitor windows_monitor
```

3. **Colocar archivos**
- `app.py` en el directorio raíz
- `index.html` en `templates/`
- `app.sh` en `linux_monitor/`
- `app.ps1` en `windows_monitor/`

4. **Instalar dependencias Python**
```bash
pip install flask
```

5. **Permisos (Linux)**
```bash
chmod +x linux_monitor/app.sh
```

6. **Permisos (Windows)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Ejecución

```bash
python app.py
```

El servidor estará disponible en: `http://localhost:8080`

---

## Características Técnicas

### Ventajas del diseño

**Multiplataforma:**
- Detección automática de SO
- Scripts nativos optimizados para cada plataforma
- Sin dependencias externas complejas

**Modular:**
- Frontend completamente desacoplado
- API REST estándar
- Scripts intercambiables

**Escalable:**
- Fácil agregar nuevas métricas
- Arquitectura preparada para múltiples servidores
- Frontend adaptable a diferentes backends

### Consideraciones de seguridad

**⚠️ Limitaciones actuales:**
- Ejecución de comandos del sistema sin validación
- Posible inyección de comandos en parámetro `path`
- Sin autenticación ni autorización
- Exposición de información sensible del sistema

**🔒 Recomendaciones para producción:**
- Implementar autenticación
- Validar y sanitizar inputs
- Limitar comandos ejecutables
- Implementar rate limiting
- Usar HTTPS
- Logs de auditoría

---

## Extensibilidad

### Agregar nuevas métricas

**1. Crear función en scripts:**
```bash
# Linux (app.sh)
get_new_metric() {
    echo "<table>...</table>"
}
```

```powershell
# Windows (app.ps1)
function Get-NewMetric {
    Write-Output "<table>...</table>"
}
```

**2. Agregar endpoint en Flask:**
```python
@app.route("/new-metric")
def new_metric():
    # Lógica similar a otros endpoints
```

**3. Agregar función JavaScript:**
```javascript
function showNewMetric() {
    fetch('/new-metric')
      .then(response => response.text())
      .then(html => {
        document.getElementById('content').innerHTML = 
          '<h2>Nueva Métrica</h2>' + html;
      });
}
```

**4. Agregar botón al menú:**
```html
<button onclick="showNewMetric()">Nueva Métrica</button>
```

### Personalización de estilos

El CSS está completamente contenido en `index.html`, facilitando la personalización:
- Cambiar colores modificando variables CSS
- Ajustar layouts modificando propiedades flexbox
- Personalizar componentes específicos

---

## Troubleshooting

### Problemas comunes

**Error: "No se puede ejecutar PowerShell"**
- Verificar política de ejecución: `Get-ExecutionPolicy`
- Cambiar política: `Set-ExecutionPolicy RemoteSigned`

**Error: "Permission denied" en Linux**
- Dar permisos de ejecución: `chmod +x linux_monitor/app.sh`

**Error: "Comando no encontrado"**
- Verificar que las herramientas del sistema estén instaladas
- Linux: `ps`, `df`, `find`, `free`, `netstat`
- Windows: PowerShell 5.0+

**Frontend no carga datos**
- Verificar que Flask esté ejecutándose en puerto 8080
- Revisar consola del navegador para errores JavaScript
- Verificar que los scripts tengan los permisos correctos

### Logs y debugging

**Activar debug en Flask:**
```python
app.run(host="0.0.0.0", port=8080, debug=True)
```

**Ver errores de scripts:**
Los errores se muestran en la respuesta HTTP y en la consola del navegador.

---

## Conclusión

Este sistema de monitoreo multiplataforma demuestra una arquitectura limpia y modular que se adapta automáticamente al sistema operativo. Combina la potencia de los scripts nativos del sistema con la flexibilidad de una API REST y la usabilidad de una interfaz web moderna.

La separación clara de responsabilidades permite el mantenimiento independiente de cada componente y facilita futuras extensiones o modificaciones del sistema.