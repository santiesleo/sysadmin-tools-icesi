# app.ps1

function Get-TopProcesses {
    $processes = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | 
        Select-Object Id, ProcessName, CPU, @{Name='CPUPercent';Expression={$_.CPU}}
    $html = "<table><tr><th>PID</th><th>Nombre</th><th>CPU %</th></tr>"
    
    foreach ($process in $processes) {
        $html += "<tr><td>$($process.Id)</td><td>$($process.ProcessName)</td><td>$($process.CPUPercent)</td></tr>"
    }
    $html += "</table>"
    Write-Output $html
}

function Get-DiskInfo {
    $disks = Get-PSDrive -PSProvider FileSystem
    $html = "<table><tr><th>Unidad</th><th>Tamaño Total (Bytes)</th><th>Espacio Libre (Bytes)</th><th>Espacio Libre (%)</th></tr>"
    
    foreach ($disk in $disks) {
        $freeSpace = $disk.Free
        $totalSpace = $disk.Used + $disk.Free
        $freePercent = [math]::Round(($freeSpace / $totalSpace) * 100, 2)
        $html += "<tr><td>$($disk.Name)</td><td>$totalSpace</td><td>$freeSpace</td><td>$freePercent%</td></tr>"
    }
    $html += "</table>"
    Write-Output $html
}

function Get-LargestFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    try {
        $file = Get-ChildItem -Path $Path -Recurse -File | 
                Sort-Object Length -Descending | 
                Select-Object -First 1
        
        if ($file) {
            $html = "<table><tr><th>Nombre</th><th>Tamaño (Bytes)</th><th>Ruta</th></tr>"
            $html += "<tr><td>$($file.Name)</td><td>$($file.Length)</td><td>$($file.FullName)</td></tr>"
            $html += "</table>"
        } else {
            $html = "<p>No se encontraron archivos en la ruta especificada.</p>"
        }
        Write-Output $html
    }
    catch {
        Write-Output "<p>Error: $_</p>"
    }
}

function Get-MemoryInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $totalPhysical = $os.TotalVisibleMemorySize * 1KB
    $freePhysical = $os.FreePhysicalMemory * 1KB
    $totalVirtual = $os.TotalVirtualMemorySize * 1KB
    $freeVirtual = $os.FreeVirtualMemory * 1KB
    
    $html = "<table><tr><th>Tipo</th><th>Total (Bytes)</th><th>Libre (Bytes)</th><th>Libre (%)</th></tr>"
    
    # Memoria física
    $freePhysicalPercent = [math]::Round(($freePhysical / $totalPhysical) * 100, 2)
    $html += "<tr><td>Memoria Física</td><td>$totalPhysical</td><td>$freePhysical</td><td>$freePhysicalPercent%</td></tr>"
    
    # Memoria virtual
    $freeVirtualPercent = [math]::Round(($freeVirtual / $totalVirtual) * 100, 2)
    $html += "<tr><td>Memoria Virtual</td><td>$totalVirtual</td><td>$freeVirtual</td><td>$freeVirtualPercent%</td></tr>"
    
    $html += "</table>"
    Write-Output $html
}

function Get-NetworkConnections {
    $connections = Get-NetTCPConnection -State Established
    $html = "<table><tr><th>Puerto Local</th><th>Puerto Remoto</th><th>Estado</th><th>PID</th></tr>"
    
    foreach ($conn in $connections) {
        $html += "<tr><td>$($conn.LocalPort)</td><td>$($conn.RemotePort)</td><td>$($conn.State)</td><td>$($conn.OwningProcess)</td></tr>"
    }
    $html += "</table>"
    Write-Output $html
}

# Función para mostrar el menú
function Show-Menu {
    $html = @"
    <div class="menu">
        <button onclick="showTopProcesses()">1. Top 5 procesos CPU</button>
        <button onclick="showDisks()">2. Filesystems/Discos</button>
        <button onclick="showLargestFile()">3. Archivo más grande</button>
        <button onclick="showMemoryInfo()">4. Memoria y Swap</button>
        <button onclick="showNetworkConnections()">5. Conexiones de red</button>
    </div>
"@
    Write-Output $html
}

# Exportar todas las funciones
Export-ModuleMember -Function Get-TopProcesses, Get-DiskInfo, Get-LargestFile, Get-MemoryInfo, Get-NetworkConnections, Show-Menu
