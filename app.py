from flask import Flask, render_template, request, jsonify
import subprocess
import platform
import os

app = Flask(__name__)

# Función para detectar el sistema operativo
def detect_os():
    """
    Detecta el entorno de ejecución:
    - Si es Windows, devuelve "windows".
    - Si es Linux y es WSL, devuelve "windows" (opcional).
    - Si es Linux, devuelve "linux".
    """
    system = platform.system()
    print(f"Detectando sistema operativo: {system}")
    if system == "Linux" and "microsoft" in platform.release().lower():
        print("Detectado: WSL en Windows. Usando PowerShell.")
        return "windows"
    elif system == "Windows":
        print("Detectado: Windows. Usando PowerShell.")
        return "windows"
    else:
        print("Detectado: Linux. Usando Bash.")
        return "linux"

# Detecta el sistema operativo al inicio de la aplicación
OS_TYPE = detect_os()

@app.route("/")
def index():
    """
    Página principal.
    """
    return render_template("index.html")

@app.route("/menu")
def menu():
    """
    Endpoint para obtener el menú de opciones.
    """
    try:
        if OS_TYPE == "windows":
            result = subprocess.run(
                ["powershell", "-Command", "& { . ./windows_monitor/app.ps1; Show-Menu }"],
                capture_output=True,
                text=True
            )
        else:
            result = subprocess.run(
                ["bash", "./linux_monitor/app.sh", "show_menu"],
                capture_output=True,
                text=True
            )

        if result.returncode == 0:
            return result.stdout
        else:
            return f"Error al obtener el menú: {result.stderr}", 500
    except Exception as e:
        return str(e), 500

@app.route("/top-processes")
def top_processes():
    """
    Endpoint para obtener los 5 procesos que más CPU consumen.
    """
    try:
        if OS_TYPE == "windows":
            result = subprocess.run(
                ["powershell", "-Command", "& { . ./windows_monitor/app.ps1; Get-TopProcesses }"],
                capture_output=True,
                text=True
            )
        else:
            result = subprocess.run(
                ["bash", "./linux_monitor/app.sh", "get_top_processes"],
                capture_output=True,
                text=True
            )

        if result.returncode == 0:
            return result.stdout
        else:
            return f"Error al obtener los procesos: {result.stderr}", 500
    except Exception as e:
        return str(e), 500

@app.route("/disks")
def disks():
    """
    Endpoint para obtener información de los discos.
    """
    try:
        if OS_TYPE == "windows":
            result = subprocess.run(
                ["powershell", "-Command", "& { . ./windows_monitor/app.ps1; Get-DiskInfo }"],
                capture_output=True,
                text=True
            )
        else:
            result = subprocess.run(
                ["bash", "./linux_monitor/app.sh", "get_disk_info"],
                capture_output=True,
                text=True
            )

        if result.returncode == 0:
            return result.stdout
        else:
            return f"Error al obtener información de discos: {result.stderr}", 500
    except Exception as e:
        return str(e), 500

@app.route("/largest-file")
def largest_file():
    """
    Endpoint para obtener el archivo más grande en un directorio.
    """
    path = request.args.get("path", ".")
    try:
        if OS_TYPE == "windows":
            result = subprocess.run(
                ["powershell", "-Command", f"& {{ . ./windows_monitor/app.ps1; Get-LargestFile -Path '{path}' }}"],
                capture_output=True,
                text=True
            )
        else:
            result = subprocess.run(
                ["bash", "./linux_monitor/app.sh", "get_largest_file", path],
                capture_output=True,
                text=True
            )

        if result.returncode == 0:
            return result.stdout
        else:
            return f"Error al buscar el archivo más grande: {result.stderr}", 500
    except Exception as e:
        return str(e), 500

@app.route("/memory")
def memory():
    """
    Endpoint para obtener información de memoria y swap.
    """
    try:
        if OS_TYPE == "windows":
            result = subprocess.run(
                ["powershell", "-Command", "& { . ./windows_monitor/app.ps1; Get-MemoryInfo }"],
                capture_output=True,
                text=True
            )
        else:
            result = subprocess.run(
                ["bash", "./linux_monitor/app.sh", "get_memory_info"],
                capture_output=True,
                text=True
            )

        if result.returncode == 0:
            return result.stdout
        else:
            return f"Error al obtener información de memoria: {result.stderr}", 500
    except Exception as e:
        return str(e), 500

@app.route("/network")
def network():
    """
    Endpoint para obtener conexiones de red establecidas.
    """
    try:
        if OS_TYPE == "windows":
            result = subprocess.run(
                ["powershell", "-Command", "& { . ./windows_monitor/app.ps1; Get-NetworkConnections }"],
                capture_output=True,
                text=True
            )
        else:
            result = subprocess.run(
                ["bash", "./linux_monitor/app.sh", "get_network_connections"],
                capture_output=True,
                text=True
            )

        if result.returncode == 0:
            return result.stdout
        else:
            return f"Error al obtener conexiones de red: {result.stderr}", 500
    except Exception as e:
        return str(e), 500

if __name__ == "__main__":
    """
    Ejecutar la aplicación Flask.
    """
    app.run(host="0.0.0.0", port=8080)
