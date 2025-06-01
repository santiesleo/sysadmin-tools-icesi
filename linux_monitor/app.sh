#!/bin/bash

# Función para obtener los 5 procesos que más CPU consumen
get_top_processes() {
    echo "<table><tr><th>PID</th><th>Nombre</th><th>CPU %</th></tr>"
    ps aux --sort=-%cpu | head -n 6 | tail -n 5 | awk '{
        printf "<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n", $2, $11, $3
    }'
    echo "</table>"
}

# Función para obtener información de los filesystems
get_disk_info() {
    echo "<table><tr><th>Filesystem</th><th>Tamaño Total (Bytes)</th><th>Espacio Libre (Bytes)</th><th>Espacio Libre (%)</th></tr>"
    df -B1 | tail -n +2 | awk '{
        printf "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n", $1, $2, $4, $5
    }'
    echo "</table>"
}

# Función para encontrar el archivo más grande en un directorio
get_largest_file() {
    local path="$1"
    if [ -z "$path" ]; then
        path="."
    fi
    
    echo "<table><tr><th>Nombre</th><th>Tamaño (Bytes)</th><th>Ruta</th></tr>"
    if [ -d "$path" ]; then
        find "$path" -type f -exec du -b {} \; | sort -nr | head -n 1 | while read size file; do
            echo "<tr><td>$(basename "$file")</td><td>$size</td><td>$file</td></tr>"
        done
    else
        echo "<tr><td colspan='3'>El directorio especificado no existe</td></tr>"
    fi
    echo "</table>"
}

# Función para obtener información de memoria y swap
get_memory_info() {
    echo "<table><tr><th>Tipo</th><th>Total (Bytes)</th><th>Libre (Bytes)</th><th>Libre (%)</th></tr>"
    
    # Memoria física
    free -b | awk 'NR==2 {
        total=$2
        free=$4
        free_percent=sprintf("%.2f", (free/total)*100)
        printf "<tr><td>Memoria Física</td><td>%s</td><td>%s</td><td>%s%%</td></tr>\n", total, free, free_percent
    }'
    
    # Memoria swap
    free -b | awk 'NR==3 {
        total=$2
        free=$4
        if (total > 0) {
            free_percent=sprintf("%.2f", (free/total)*100)
        } else {
            free_percent="0.00"
        }
        printf "<tr><td>Memoria Swap</td><td>%s</td><td>%s</td><td>%s%%</td></tr>\n", total, free, free_percent
    }'
    
    echo "</table>"
}

# Función para obtener conexiones de red establecidas
get_network_connections() {
    echo "<table><tr><th>Puerto Local</th><th>Puerto Remoto</th><th>Estado</th><th>PID</th></tr>"
    netstat -tnp 2>/dev/null | grep ESTABLISHED | awk '{
        split($4, local, ":")
        split($5, remote, ":")
        printf "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n", 
            local[2], remote[2], $6, $7
    }'
    echo "</table>"
}

# Función para mostrar el menú
show_menu() {
    echo '<div class="menu">
        <button onclick="showTopProcesses()">1. Top 5 procesos CPU</button>
        <button onclick="showDisks()">2. Filesystems/Discos</button>
        <button onclick="showLargestFile()">3. Archivo más grande</button>
        <button onclick="showMemoryInfo()">4. Memoria y Swap</button>
        <button onclick="showNetworkConnections()">5. Conexiones de red</button>
    </div>'
}

# Ejecutar la función correspondiente basada en el argumento
case "$1" in
    "get_top_processes")
        get_top_processes
        ;;
    "get_disk_info")
        get_disk_info
        ;;
    "get_largest_file")
        get_largest_file "$2"
        ;;
    "get_memory_info")
        get_memory_info
        ;;
    "get_network_connections")
        get_network_connections
        ;;
    "show_menu")
        show_menu
        ;;
    *)
        echo "Uso: $0 {get_top_processes|get_disk_info|get_largest_file <path>|get_memory_info|get_network_connections|show_menu}"
        exit 1
        ;;
esac
